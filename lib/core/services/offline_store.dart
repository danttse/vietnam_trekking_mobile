import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../database/upsert.dart';
import '../database/models/track_point.dart';
import 'journey_track.dart';
import 'token_storage.dart';
import 'trekking_upload_service.dart';

/// Public catalog snapshots and account-scoped durable writes share the app's
/// SQLite database. Outbox writes and their local state commit atomically.
class OfflineStore {
  final DatabaseHelper databaseHelper;
  final Future<String?> Function() ownerProvider;
  final Future<String> Function(String path, Dio trekking)? markerImageUploader;
  Future<void>? _syncing;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();
  Stream<String> get changes => _changes.stream;

  OfflineStore({
    DatabaseHelper? databaseHelper,
    Future<String?> Function()? ownerProvider,
    this.markerImageUploader,
  }) : databaseHelper = databaseHelper ?? DatabaseHelper.instance,
       ownerProvider = ownerProvider ?? currentOwner;

  static final instance = OfflineStore();

  static String? ownerFromToken(String? token) {
    if (token == null) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))),
      ) as Map;
      return (payload['userId'] ?? payload['sub'] ?? payload['id'])?.toString();
    } catch (_) {
      return null;
    }
  }

  // Token payload selects a local cache; server authentication still validates
  // the token. No invented "local_user" identity is used for private data.
  static Future<String?> currentOwner() async =>
      ownerFromToken(await const SecureTokenStorage().getAccessToken());
  Future<String> requireOwner() async {
    final owner = await ownerProvider();
    if (owner == null || owner.isEmpty)
      throw StateError('Vui lòng đăng nhập để lưu dữ liệu offline.');
    return owner;
  }

  static bool canUseCache(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      (e.response?.statusCode ?? 0) >= 500;

  Future<dynamic> read(String resource, {String owner = ''}) async {
    final db = await databaseHelper.database;
    return _read(db, resource, owner);
  }

  /// Bound browsing snapshots without touching downloaded offline trip packages.
  Future<void> pruneExplorePages(int keep) async {
    final db = await databaseHelper.database;
    await db.rawDelete(
      'DELETE FROM offline_snapshots WHERE ownerId = ? '
      'AND resource LIKE ? AND resource NOT IN ('
      'SELECT resource FROM offline_snapshots WHERE ownerId = ? AND resource LIKE ? '
      'ORDER BY updatedAt DESC, resource LIMIT ?)',
      ['', '/explore-pages/v2/%', '', '/explore-pages/v2/%', keep],
    );
  }

  Future<void> invalidateExplorePages(String prefix, String except) async {
    final db = await databaseHelper.database;
    await db.delete(
      'offline_snapshots',
      where: 'ownerId = ? AND substr(resource, 1, ?) = ? AND resource <> ?',
      whereArgs: ['', prefix.length, prefix, except],
    );
  }

  Future<dynamic> _read(
    DatabaseExecutor db,
    String resource,
    String owner,
  ) async {
    final rows = await db.query(
      'offline_snapshots',
      where: 'ownerId = ? AND resource = ?',
      whereArgs: [owner, resource],
      limit: 1,
    );
    if (rows.isNotEmpty) return jsonDecode(rows.first['payload'] as String);
    // Preserve usable caches made by older app versions after the v4 upgrade.
    if (owner.isNotEmpty) {
      if (RegExp(r'^/journeys/[^/]+$').hasMatch(resource)) {
        final id = resource.split('/')[2];
        final journeys = await db.query(
          'local_journeys',
          where: '(localJourneyId = ? OR serverJourneyId = ?) AND userId = ?',
          whereArgs: [id, id, owner],
        );
        if (journeys.isNotEmpty) return _legacyJourney(journeys.first);
      }
      return null;
    }
    Map<String, dynamic> placeJson(Map<String, Object?> row) => {
      ...row,
      'location': {
        'type': 'Point',
        'coordinates': [row['longitude'] ?? 0, row['latitude'] ?? 0],
      },
      'images': [if (row['imageUrl'] != null) row['imageUrl']],
      'offlineMap': {
        'available': row['offlineMapAvailable'] == 1,
        'version': row['offlineMapVersion'] ?? 0,
      },
    };
    Map<String, dynamic> routeJson(Map<String, Object?> row) => {
      ...row,
      'startLocation': {
        'type': 'Point',
        'coordinates': [row['startLongitude'] ?? 0, row['startLatitude'] ?? 0],
      },
      'endLocation': {
        'type': 'Point',
        'coordinates': [row['endLongitude'] ?? 0, row['endLatitude'] ?? 0],
      },
      'offlineMap': {'version': row['mapVersion'] ?? 0},
    };
    if (resource == '/places') {
      final places = await db.query('cached_places', where: "name != ''");
      return places.isEmpty ? null : places.map(placeJson).toList();
    }
    if (RegExp(r'^/places/[^/]+$').hasMatch(resource)) {
      final places = await db.query(
        'cached_places',
        where: 'trekkingPlaceId = ?',
        whereArgs: [resource.split('/')[2]],
      );
      return places.isEmpty ? null : placeJson(places.first);
    }
    if (RegExp(r'^/routes/[^/]+$').hasMatch(resource)) {
      final routes = await db.query(
        'cached_routes',
        where: 'trekkingRouteId = ?',
        whereArgs: [resource.split('/')[2]],
      );
      return routes.isEmpty ? null : routeJson(routes.first);
    }
    if (RegExp(r'^/places/[^/]+/routes$').hasMatch(resource)) {
      final routes = await db.query(
        'cached_routes',
        where: 'trekkingPlaceId = ?',
        whereArgs: [resource.split('/')[2]],
      );
      return routes.isEmpty ? null : routes.map(routeJson).toList();
    }
    if (RegExp(r'^/routes/[^/]+/milestones$').hasMatch(resource)) {
      final milestones = await db.query(
        'cached_milestones',
        where: 'trekkingRouteId = ? AND sequenceNumber >= 0',
        whereArgs: [resource.split('/')[2]],
        orderBy: 'sequenceNumber',
      );
      return milestones.isEmpty
          ? null
          : milestones
                .map(
                  (row) => {
                    ...row,
                    'sequence': row['sequenceNumber'],
                    'required': row['required'] == 1,
                    'location': {
                      'type': 'Point',
                      'coordinates': [row['longitude'], row['latitude']],
                    },
                  },
                )
                .toList();
    }
    return null;
  }

  Future<void> _write(
    DatabaseExecutor db,
    String resource,
    dynamic data,
    String owner,
  ) async {
    await db.rawInsert(
      'INSERT INTO offline_snapshots(ownerId,resource,payload,updatedAt) VALUES(?,?,?,?) '
      'ON CONFLICT(ownerId,resource) DO UPDATE SET payload=excluded.payload,updatedAt=excluded.updatedAt',
      [
        owner,
        resource,
        jsonEncode(data),
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }

  Future<void> cache(String resource, dynamic data, {String owner = ''}) async {
    final db = await databaseHelper.database;
    await db.transaction((tx) => _cache(tx, resource, data, owner));
  }

  Future<void> _cache(
    DatabaseExecutor db,
    String resource,
    dynamic data,
    String owner,
  ) async {
    await _write(db, resource, data, owner);
    if (owner.isNotEmpty) return;
    if (resource == '/places' && data is List) {
      for (final place in data) {
        await _cache(
          db,
          '/places/${place['trekkingPlaceId'] ?? place['_id']}',
          place,
          '',
        );
      }
    } else if (RegExp(r'^/places/[^/]+$').hasMatch(resource) && data is Map) {
      final id = data['trekkingPlaceId'] ?? data['_id'];
      final province = data['provinceId'];
      if (province is String && province.isNotEmpty) {
        await db.insert('cached_provinces', {
          'provinceId': province,
          'name': data['provinceName'] ?? province,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      final point = (data['location'] as Map?)?['coordinates'] as List?;
      await upsertRow(db, 'cached_places', {
        'trekkingPlaceId': id,
        'name': data['name'] ?? '',
        'provinceId': province is String && province.isNotEmpty
            ? province
            : null,
        'latitude': point?.last,
        'longitude': point?.first,
        'status': data['status'] ?? 'ACTIVE',
      }, 'trekkingPlaceId');
    } else if (RegExp(r'^/places/[^/]+/routes$').hasMatch(resource) &&
        data is List) {
      for (final route in data) {
        await _cache(
          db,
          '/routes/${route['trekkingRouteId'] ?? route['_id']}',
          route,
          '',
        );
      }
    } else if (RegExp(r'^/routes/[^/]+$').hasMatch(resource) && data is Map) {
      final placeId = data['trekkingPlaceId']?.toString() ?? '';
      await db.insert('cached_places', {
        'trekkingPlaceId': placeId,
        'name': data['placeName'] ?? '',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await upsertRow(db, 'cached_routes', {
        'trekkingRouteId': data['trekkingRouteId'] ?? data['_id'],
        'trekkingPlaceId': placeId,
        'name': data['name'] ?? '',
        'distanceMeters': data['distanceMeters'],
        'estimatedDurationMinutes': data['estimatedDurationMinutes'],
        'encodedPolyline': data['encodedPolyline'],
      }, 'trekkingRouteId');
    } else if (RegExp(r'^/routes/[^/]+/milestones$').hasMatch(resource) &&
        data is List) {
      final routeId = resource.split('/')[2];
      // A backend reorder must not collide with the route/sequence UNIQUE key.
      // Retain removed milestone IDs because existing check-ins reference them.
      await db.rawUpdate(
        'UPDATE cached_milestones SET sequenceNumber = -1000000 - rowid WHERE trekkingRouteId = ?',
        [routeId],
      );
      for (final milestone in data) {
        final point = (milestone['location'] as Map?)?['coordinates'] as List?;
        await upsertRow(db, 'cached_milestones', {
          'milestoneId': milestone['milestoneId'] ?? milestone['_id'],
          'trekkingRouteId': routeId,
          'name': milestone['name'] ?? '',
          'type': milestone['type'] ?? 'CHECKPOINT',
          'sequenceNumber':
              milestone['sequence'] ?? milestone['sequenceNumber'] ?? 0,
          'latitude': point?.last ?? milestone['latitude'] ?? 0,
          'longitude': point?.first ?? milestone['longitude'] ?? 0,
          'altitude': milestone['altitude'] ?? milestone['altitudeMeters'],
          'checkinRadiusMeters': milestone['checkinRadiusMeters'] ?? 50,
        }, 'milestoneId');
      }
    }
  }

  Future<void> cachePackage(Map<String, dynamic> package) async {
    final place = package['place'];
    if (place is Map)
      await cache('/places/${place['trekkingPlaceId'] ?? place['_id']}', place);
    final route = package['route'];
    if (route is Map) {
      final id = route['trekkingRouteId'] ?? route['_id'];
      await cache('/routes/$id', route);
      await cache('/routes/$id/milestones', package['milestones'] ?? []);
    }
    if (package['routes'] is List && place is Map) {
      await cache(
        '/places/${place['trekkingPlaceId'] ?? place['_id']}/routes',
        package['routes'],
      );
    }
  }

  Future<void> _saveJourney(
    DatabaseExecutor db,
    Map<String, dynamic> json,
    String owner, {
    String? localId,
  }) async {
    final id =
        localId ??
        json['clientJourneyId']?.toString() ??
        json['journeyId']?.toString() ??
        json['_id'].toString();
    await db.insert('local_user', {
      'userId': owner,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    final placeId = json['trekkingPlaceId'].toString();
    final routeId = json['trekkingRouteId'].toString();
    await db.insert('cached_places', {
      'trekkingPlaceId': placeId,
      'name': '',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('cached_routes', {
      'trekkingRouteId': routeId,
      'trekkingPlaceId': placeId,
      'name': '',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    final province = json['provinceId'];
    if (province is String && province.isNotEmpty) {
      await db.insert('cached_provinces', {
        'provinceId': province,
        'name': province,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    final serverId = json['offlineSyncStatus'] == 'PENDING'
        ? json['serverJourneyId']
        : json['journeyId'] ?? json['_id'];
    await upsertRow(db, 'local_journeys', {
      'localJourneyId': id,
      'serverJourneyId': serverId,
      'userId': owner,
      'trekkingPlaceId': placeId,
      'trekkingRouteId': routeId,
      'provinceId': province is String ? province : null,
      'name': json['name'] ?? '',
      'status': json['status'] ?? 'PLANNED',
      'plannedStartAt': json['plannedStartAt'],
      'plannedEndAt': json['plannedEndAt'],
      'note': json['note'],
      'participantCount': json['participantCount'] ?? 1,
      'startedAt': json['startedAt'],
      'completedAt': json['completedAt'],
      'distanceMeters': (json['statistics'] as Map?)?['distanceMeters'] ?? 0,
      'durationSeconds': (json['statistics'] as Map?)?['durationSeconds'] ?? 0,
      'elevationGain': (json['statistics'] as Map?)?['elevationGain'] ?? 0,
      'maxAltitude': (json['statistics'] as Map?)?['maxAltitude'] ?? 0,
      'checkinCount': json['checkinCount'] ?? 0,
      'markerCount': json['markerCount'] ?? 0,
      'syncStatus': json['offlineSyncStatus'] ?? 'SYNCED',
      'createdAt': json['createdAt'],
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }, 'localJourneyId');
    await _write(db, '/journeys/$id', {
      ...json,
      'userId': owner,
      'clientJourneyId': id,
      'serverJourneyId': serverId,
      'offlineSyncStatus': json['offlineSyncStatus'] ?? 'SYNCED',
    }, owner);
  }

  Future<void> cacheJourneys(
    List<Map<String, dynamic>> journeys,
    String owner,
  ) async {
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      for (final j in journeys) {
        final id = j['clientJourneyId'] ?? j['journeyId'] ?? j['_id'];
        final pending = await tx.query(
          'offline_outbox',
          where: "ownerId = ? AND journeyRef = ? AND state IN ('PENDING','FAILED')",
          whereArgs: [owner, id],
        );
        if (pending.isEmpty) await _saveJourney(tx, j, owner);
      }
    });
  }

  Future<List<Map<String, dynamic>>> journeys(String owner) async {
    final db = await databaseHelper.database;
    final rows = await db.query(
      'local_journeys',
      where: 'userId = ?',
      whereArgs: [owner],
      orderBy: 'createdAt DESC',
    );
    final items = <Map<String, dynamic>>[];
    for (final row in rows) {
      final snapshot = await _read(
        db,
        '/journeys/${row['localJourneyId']}',
        owner,
      );
      if (snapshot is Map) {
        items.add(Map<String, dynamic>.from(snapshot));
      } else {
        items.add(_legacyJourney(row));
      }
    }
    return items;
  }

  Map<String, dynamic> _legacyJourney(Map<String, Object?> row) => {
    ...row,
    'journeyId': row['serverJourneyId'] ?? row['localJourneyId'],
    'clientJourneyId': row['localJourneyId'],
    'offlineSyncStatus': row['syncStatus'],
    'statistics': {
      'distanceMeters': row['distanceMeters'],
      'durationSeconds': row['durationSeconds'],
      'elevationGain': row['elevationGain'],
      'maxAltitude': row['maxAltitude'],
    },
  };

  Future<Map<String, Object?>> _journeyRow(
    DatabaseExecutor db,
    String ref,
    String owner,
  ) async {
    final rows = await db.query(
      'local_journeys',
      where: '(localJourneyId = ? OR serverJourneyId = ?) AND userId = ?',
      whereArgs: [ref, ref, owner],
      limit: 1,
    );
    if (rows.isEmpty)
      throw StateError('Hành trình chưa được lưu trên thiết bị.');
    return rows.first;
  }

  Future<String> localJourneyId(String ref) async =>
      (await _journeyRow(
            await databaseHelper.database,
            ref,
            await requireOwner(),
          ))['localJourneyId']
          as String;

  Future<List<TrackPoint>> trackPoints(String ref) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    final row = await _journeyRow(db, ref, owner);
    final rows = await db.query(
      'track_points',
      where: 'localJourneyId = ?',
      whereArgs: [row['localJourneyId']],
      orderBy: 'recordedAt ASC',
    );
    if (await requireOwner() != owner)
      throw StateError('Tài khoản đã thay đổi.');
    return rows.map(TrackPoint.fromMap).toList();
  }

  Future<bool> isRecordingTrack(String ref) async {
    final owner = await requireOwner();
    final id = await localJourneyId(ref);
    final saved = await read('/journeys/$id/backtrack', owner: owner);
    return saved is Map && saved['recording'] == true;
  }

  Future<void> setTrackRecording(String ref, bool recording) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      final row = await _journeyRow(tx, ref, owner);
      if (recording && row['status'] != 'ACTIVE') {
        throw StateError('Chỉ ghi GPS khi hành trình đang đi.');
      }
      await _write(tx, '/journeys/${row['localJourneyId']}/backtrack', {
        'recording': recording,
      }, owner);
    });
    _changes.add(owner);
  }

  /// The transaction checks owner, lifecycle and GPS quality before persisting.
  Future<bool> recordTrackPoint(
    TrackPoint point, {
    required String owner,
  }) async {
    if (await requireOwner() != owner)
      throw StateError('Tài khoản đã thay đổi.');
    final db = await databaseHelper.database;
    return db.transaction((tx) async {
      final row = await _journeyRow(tx, point.localJourneyId, owner);
      final id = row['localJourneyId'] as String;
      final settings = await _read(tx, '/journeys/$id/backtrack', owner);
      if (row['status'] != 'ACTIVE' ||
          settings is! Map ||
          settings['recording'] != true)
        return false;
      final rows = await tx.query(
        'track_points',
        where: 'localJourneyId = ?',
        whereArgs: [id],
        orderBy: 'recordedAt DESC',
        limit: 1,
      );
      final previous = rows.isEmpty ? null : TrackPoint.fromMap(rows.first);
      if (!JourneyTrack.accepts(point, previous, DateTime.now().toUtc()))
        return false;
      await tx.insert('track_points', {...point.toMap(), 'localJourneyId': id});
      return true;
    });
  }

  Future<void> _enqueue(
    DatabaseExecutor db,
    String id,
    String owner,
    String method,
    String path,
    Map<String, dynamic> body,
    String? ref,
  ) async {
    await db.insert('offline_outbox', {
      'operationId': id,
      'ownerId': owner,
      'method': method,
      'path': path,
      'body': jsonEncode(body),
      'journeyRef': ref,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<String> createJourney(Map<String, dynamic> body) async {
    final owner = await requireOwner();
    final id = body['clientJourneyId'].toString();
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      final existing = await _read(tx, '/journeys/$id', owner);
      if (existing != null) {
        final failed = await tx.query(
          'offline_outbox',
          where: "operationId = ? AND ownerId = ? AND state = 'FAILED'",
          whereArgs: [id, owner],
        );
        if (failed.isEmpty) return;
        await tx.update(
          'offline_outbox',
          {'body': jsonEncode(body), 'state': 'PENDING', 'lastError': null},
          where: 'operationId = ?',
          whereArgs: [id],
        );
      }
      await _saveJourney(
        tx,
        {
          ...body,
          'journeyId': id,
          'userId': owner,
          'status': 'PLANNED',
          'offlineSyncStatus': 'PENDING',
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        },
        owner,
        localId: id,
      );
      await _enqueue(tx, id, owner, 'POST', '/journeys', body, id);
    });
    return id;
  }

  Future<String> transition(
    String ref,
    String action, {
    Map<String, dynamic> body = const {},
  }) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    final operationId =
        'journey-action-${DateTime.now().microsecondsSinceEpoch}';
    const transitions = {
      'start': 'ACTIVE',
      'pause': 'PAUSED',
      'resume': 'ACTIVE',
      'complete': 'COMPLETED',
      'cancel': 'CANCELLED',
    };
    await db.transaction((tx) async {
      final row = await _journeyRow(tx, ref, owner);
      final id = row['localJourneyId'] as String;
      final failedCreate = await tx.query(
        'offline_outbox',
        where: "ownerId = ? AND journeyRef = ? AND path = '/journeys' AND state = 'FAILED'",
        whereArgs: [owner, id],
      );
      if (failedCreate.isNotEmpty)
        throw StateError(
          failedCreate.first['lastError']?.toString() ??
              'Hành trình chưa được backend chấp nhận.',
        );
      final json = Map<String, dynamic>.from(
        await _read(tx, '/journeys/$id', owner) as Map,
      );
      final status = json['status'];
      final allowed = switch (action) {
        'start' => status == 'PLANNED',
        'pause' => status == 'ACTIVE',
        'resume' => status == 'PAUSED',
        'complete' => status == 'ACTIVE' || status == 'PAUSED',
        'cancel' =>
          status == 'PLANNED' || status == 'ACTIVE' || status == 'PAUSED',
        _ => false,
      };
      if (!allowed)
        throw StateError('Không thể đổi trạng thái hành trình hiện tại.');
      if (action == 'complete') {
        final rows = await tx.query(
          'track_points',
          where: 'localJourneyId = ?',
          whereArgs: [id],
          orderBy: 'recordedAt ASC',
        );
        final recorded = JourneyTrack.completionBody(
          rows.map(TrackPoint.fromMap).toList(),
        );
        // Every completion entry point (including check-in) sends the saved GPS.
        body = {...body, ...recorded};
      }
      if (action == 'complete' || action == 'cancel') {
        await _write(tx, '/journeys/$id/backtrack', {
          'recording': false,
        }, owner);
      }
      json.addAll(body);
      json['status'] = transitions[action];
      json['offlineSyncStatus'] = 'PENDING';
      json['serverJourneyId'] = row['serverJourneyId'];
      if (action == 'start')
        json['startedAt'] = DateTime.now().toUtc().toIso8601String();
      if (action == 'complete')
        json['completedAt'] = DateTime.now().toUtc().toIso8601String();
      await _saveJourney(tx, json, owner, localId: id);
      await tx.update(
        'offline_outbox',
        {'state': 'SUPERSEDED'},
        where:
            "ownerId = ? AND journeyRef = ? AND path = ? AND state = 'FAILED'",
        whereArgs: [owner, id, '/journeys/@journey/$action'],
      );
      await _enqueue(
        tx,
        operationId,
        owner,
        'POST',
        '/journeys/@journey/$action',
        {
          ...body,
          if (action == 'start') 'startedAt': json['startedAt'],
          if (action == 'complete') 'completedAt': json['completedAt'],
          '_previousStatus': status,
        },
        id,
      );
    });
    _changes.add(owner);
    return operationId;
  }

  Future<String> checkin(String journeyRef, Map<String, dynamic> body) async {
    body = {
      ...body,
      'checkedAt':
          body['checkedAt'] ?? DateTime.now().toUtc().toIso8601String(),
    };
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    late String id;
    await db.transaction((tx) async {
      final row = await _journeyRow(tx, journeyRef, owner);
      final localId = row['localJourneyId'] as String;
      if (row['status'] != 'ACTIVE')
        throw StateError('Hãy bắt đầu hành trình trước khi check-in.');
      id = 'checkin-$owner-$localId-${body['milestoneId']}';
      final existing = await tx.query(
        'offline_checkins',
        where: 'localCheckinId = ?',
        whereArgs: [id],
      );
      if (existing.isNotEmpty) {
        if (existing.first['syncStatus'] != 'FAILED') return;
        await tx.update(
          'offline_checkins',
          {
            'latitude': body['latitude'],
            'longitude': body['longitude'],
            'accuracyMeters': body['accuracyMeters'],
            'checkedAt': body['checkedAt'],
            'verificationStatus': 'PENDING',
            'syncStatus': 'PENDING',
          },
          where: 'localCheckinId = ?',
          whereArgs: [id],
        );
        await tx.update(
          'offline_outbox',
          {
            'body': jsonEncode({...body, 'clientCheckinId': id}),
            'state': 'PENDING',
            'lastError': null,
          },
          where: 'operationId = ? AND ownerId = ?',
          whereArgs: [id, owner],
        );
        return;
      }
      await tx.insert('offline_checkins', {
        'localCheckinId': id,
        'localJourneyId': localId,
        'milestoneId': body['milestoneId'],
        'userId': owner,
        'latitude': body['latitude'],
        'longitude': body['longitude'],
        'accuracyMeters': body['accuracyMeters'],
        'checkedAt': body['checkedAt'],
        'verificationStatus': 'PENDING',
        'syncStatus': 'PENDING',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      await _enqueue(tx, id, owner, 'POST', '/checkins', {
        ...body,
        'clientCheckinId': id,
      }, localId);
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> checkins(String ref) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    final row = await _journeyRow(db, ref, owner);
    final rows = await db.query(
      'offline_checkins',
      where: 'localJourneyId = ? AND userId = ?',
      whereArgs: [row['localJourneyId'], owner],
    );
    return Future.wait(
      rows.map((r) async {
        final snapshot = await _read(
          db,
          '/checkins/${r['localCheckinId']}',
          owner,
        );
        return <String, dynamic>{
          if (snapshot is Map) ...Map<String, dynamic>.from(snapshot),
          'checkinId': r['serverCheckinId'],
          'clientCheckinId': r['localCheckinId'],
          'milestoneId': r['milestoneId'],
          'checkedAt': r['checkedAt'],
          'offlineSyncStatus': r['syncStatus'],
          'verification': {'status': r['verificationStatus']},
        };
      }),
    );
  }

  Future<void> cacheCheckins(String ref, List<dynamic> data) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      final row = await _journeyRow(tx, ref, owner);
      for (final value in data) {
        final c = value as Map;
        final existing = await tx.query(
          'offline_checkins',
          where: 'localJourneyId = ? AND milestoneId = ? AND userId = ?',
          whereArgs: [row['localJourneyId'], c['milestoneId'], owner],
        );
        final id = existing.isEmpty
            ? c['clientCheckinId'] ??
                  'server-${c['milestoneCheckinId'] ?? c['checkinId'] ?? c['_id']}'
            : existing.first['localCheckinId'];
        final coordinates = (c['location'] as Map?)?['coordinates'] as List?;
        await upsertRow(tx, 'offline_checkins', {
          'localCheckinId': id,
          'serverCheckinId':
              c['milestoneCheckinId'] ?? c['checkinId'] ?? c['_id'],
          'localJourneyId': row['localJourneyId'],
          'milestoneId': c['milestoneId'],
          'userId': owner,
          'latitude': coordinates?.last ?? c['latitude'] ?? 0,
          'longitude': coordinates?.first ?? c['longitude'] ?? 0,
          'checkedAt': c['checkedAt'],
          'verificationStatus': (c['verification'] as Map?)?['status'],
          'syncStatus': 'SYNCED',
        }, 'localCheckinId');
        await _write(tx, '/checkins/$id', c, owner);
      }
    });
  }

  Future<String> markProvince(String provinceId, bool visited) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    final id = 'province-${DateTime.now().microsecondsSinceEpoch}';
    await db.transaction((tx) async {
      final provinces = await _read(tx, '/visits/provinces/me', owner) as List?;
      if (provinces == null)
        throw StateError(
          'Hãy tải danh sách tỉnh một lần trước khi dùng offline.',
        );
      final index = provinces.indexWhere((p) => p['provinceId'] == provinceId);
      if (index < 0) throw StateError('Không tìm thấy mã tỉnh trên thiết bị.');
      final item = Map<String, dynamic>.from(provinces[index] as Map);
      item['manualMarked'] = visited;
      if (item['visitStatus'] != 'VERIFIED')
        item['visitStatus'] = visited ? 'SELF_REPORTED' : 'UNVISITED';
      provinces[index] = item;
      await _write(tx, '/visits/provinces/me', provinces, owner);
      await _enqueue(
        tx,
        id,
        owner,
        'PATCH',
        '/visits/provinces/me/$provinceId',
        {'visited': visited},
        null,
      );
      await _projectProvinces(tx, provinces, owner);
    });
    return id;
  }

  Future<void> cacheProvinces(List<dynamic> data, String owner) async {
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      final pending = await tx.query(
        'offline_outbox',
        where: "ownerId = ? AND path LIKE '/visits/provinces/me/%' AND state = 'PENDING'",
        whereArgs: [owner],
        orderBy: 'createdAt ASC',
      );
      final merged = data
          .map((p) => Map<String, dynamic>.from(p as Map))
          .toList();
      for (final op in pending) {
        final id = (op['path'] as String).split('/').last;
        final visited =
            (jsonDecode(op['body'] as String) as Map)['visited'] == true;
        for (final p in merged.where((p) => p['provinceId'] == id)) {
          p['manualMarked'] = visited;
          if (p['visitStatus'] != 'VERIFIED')
            p['visitStatus'] = visited ? 'SELF_REPORTED' : 'UNVISITED';
        }
      }
      await _write(tx, '/visits/provinces/me', merged, owner);
      await _projectProvinces(tx, merged, owner);
    });
  }

  Future<void> _projectProvinces(
    DatabaseExecutor db,
    List<dynamic> data,
    String owner,
  ) async {
    for (final item in data) {
      final p = item as Map;
      final id = p['provinceId']?.toString();
      if (id == null || id.isEmpty) continue;
      await upsertRow(db, 'cached_provinces', {
        'provinceId': id,
        'name': p['name'] ?? id,
        'code': p['code'],
        'region': p['region'],
      }, 'provinceId');
      if (p['visitStatus'] == 'UNVISITED') {
        await db.delete(
          'visited_provinces',
          where: 'ownerId = ? AND provinceId = ?',
          whereArgs: [owner, id],
        );
        continue;
      }
      final pending = await db.query(
        'offline_outbox',
        where: "ownerId = ? AND path = ? AND state = 'PENDING'",
        whereArgs: [owner, '/visits/provinces/me/$id'],
      );
      await db.rawInsert(
        'INSERT INTO visited_provinces(ownerId,provinceId,name,firstVisitedAt,lastVisitedAt,visitCount,source,syncStatus,updatedAt) '
        'VALUES(?,?,?,?,?,?,?,?,?) ON CONFLICT(ownerId,provinceId) DO UPDATE SET name=excluded.name,firstVisitedAt=excluded.firstVisitedAt,'
        'lastVisitedAt=excluded.lastVisitedAt,visitCount=excluded.visitCount,source=excluded.source,syncStatus=excluded.syncStatus,updatedAt=excluded.updatedAt',
        [
          owner,
          id,
          p['name'] ?? id,
          p['firstVisitedAt'],
          p['lastVisitedAt'],
          p['visitCount'] ?? 1,
          p['visitStatus'] == 'VERIFIED' ? 'GPS' : 'MANUAL',
          pending.isEmpty ? 'SYNCED' : 'PENDING',
          DateTime.now().toUtc().toIso8601String(),
        ],
      );
    }
  }

  Future<void> createMarker(
    Map<String, Object?> marker,
    List<Map<String, Object?>> media,
  ) async {
    final owner = await requireOwner();
    if (marker['userId'] != owner)
      throw StateError('Tài khoản của marker không khớp.');
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      final journey = await _journeyRow(
        tx,
        marker['localJourneyId'] as String,
        owner,
      );
      if (journey['status'] != 'ACTIVE' && journey['status'] != 'PAUSED') {
        throw StateError(
          'Chỉ có thể đánh dấu cột mốc khi hành trình đang diễn ra hoặc tạm dừng.',
        );
      }
      final ref = journey['localJourneyId'] as String;
      final id = marker['localMarkerId'] as String;
      await tx.insert('local_journey_markers', {
        ...marker,
        'localJourneyId': ref,
        'syncStatus': 'PENDING_SYNC',
      });
      for (final file in media) {
        await tx.insert('local_marker_media', file);
      }
      await _enqueue(
        tx,
        'marker-$id',
        owner,
        'POST',
        '/journeys/@journey/markers',
        {
          'clientMarkerId': id,
          'name': marker['name'],
          'type': marker['type'],
          'note': marker['note'],
          'location': {
            'type': 'Point',
            'coordinates': [marker['longitude'], marker['latitude']],
          },
          'altitude': marker['altitude'],
          'accuracyMeters': marker['accuracyMeters'],
          'markedAt': marker['markedAt'],
          '_markerRef': id,
        },
        ref,
      );
    });
  }

  Future<void> changeMarker(
    String id, {
    Map<String, dynamic>? values,
    List<String>? mediaLocalPaths,
    List<String>? mediaRemoteUrls,
    bool delete = false,
  }) async {
    final owner = await requireOwner();
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      final rows = await tx.query(
        'local_journey_markers',
        where: 'localMarkerId = ? AND userId = ?',
        whereArgs: [id, owner],
      );
      if (rows.isEmpty)
        throw StateError('Không tìm thấy marker của tài khoản.');
      final marker = rows.first;
      if (mediaRemoteUrls != null) {
        final remoteFiles = await tx.query(
          'local_marker_media',
          where: 'localMarkerId = ? AND localPath = ?',
          whereArgs: [id, ''],
        );
        for (final file in remoteFiles) {
          if (!mediaRemoteUrls.contains(file['remoteUrl'])) {
            await tx.delete(
              'local_marker_media',
              where: 'localMarkerMediaId = ?',
              whereArgs: [file['localMarkerMediaId']],
            );
          }
        }
      }
      if (mediaLocalPaths != null) {
        final files = await tx.query(
          'local_marker_media',
          where: 'localMarkerId = ?',
          whereArgs: [id],
        );
        for (final file in files) {
          final path = file['localPath'] as String;
          if (path.isNotEmpty && !mediaLocalPaths.contains(path)) {
            await tx.delete(
              'local_marker_media',
              where: 'localMarkerMediaId = ?',
              whereArgs: [file['localMarkerMediaId']],
            );
          }
        }
        for (var i = 0; i < mediaLocalPaths.length; i++) {
          final path = mediaLocalPaths[i];
          if (files.any((file) => file['localPath'] == path)) continue;
          final now = DateTime.now().toUtc().toIso8601String();
          await tx.insert('local_marker_media', {
            'localMarkerMediaId':
                '$id-media-${DateTime.now().microsecondsSinceEpoch}-$i',
            'localMarkerId': id,
            'localPath': path,
            'type': 'IMAGE',
            'uploadStatus': 'LOCAL',
            'createdAt': now,
          });
        }
      }
      await tx.update(
        'local_journey_markers',
        {...?values, 'syncStatus': delete ? 'PENDING_DELETE' : 'PENDING_SYNC'},
        where: 'localMarkerId = ?',
        whereArgs: [id],
      );
      await _enqueue(
        tx,
        'marker-action-${DateTime.now().microsecondsSinceEpoch}',
        owner,
        delete ? 'DELETE' : 'PUT',
        '/journeys/@journey/markers/@marker',
        {...?values, '_markerRef': id},
        marker['localJourneyId'] as String,
      );
    });
  }

  Future<String?> operationError(String id) async {
    final db = await databaseHelper.database;
    final rows = await db.query(
      'offline_outbox',
      where: "operationId = ? AND ownerId = ? AND state = 'FAILED'",
      whereArgs: [id, await requireOwner()],
    );
    return rows.isEmpty ? null : rows.first['lastError']?.toString();
  }

  Future<String> submitContribution(
    String type,
    Map<String, dynamic> body,
  ) async {
    if (!['ROUTE_SUBMISSION', 'PLACE_SUGGESTION'].contains(type))
      throw ArgumentError('Unknown contribution type');
    final owner = await requireOwner();
    final id =
        body['clientOperationId']?.toString() ??
        'contribution-${DateTime.now().microsecondsSinceEpoch}';
    final payload = {...body, 'clientOperationId': id};
    final db = await databaseHelper.database;
    await db.transaction((tx) async {
      await tx.insert('local_user', {
        'userId': owner,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      String? journeyRef;
      if (type == 'ROUTE_SUBMISSION') {
        final journey = await _journeyRow(
          tx,
          body['sourceJourneyId'].toString(),
          owner,
        );
        final allowed = body['contributionKind'] == 'MARKERS'
            ? ['ACTIVE', 'PAUSED', 'COMPLETED']
            : ['COMPLETED'];
        if (!allowed.contains(journey['status']))
          throw StateError('Chỉ có thể đóng góp từ hành trình đã hoàn thành.');
        journeyRef = journey['localJourneyId'] as String;
      }
      final existing = await tx.query(
        'local_contributions',
        where: 'localContributionId = ? AND userId = ?',
        whereArgs: [id, owner],
      );
      if (existing.isNotEmpty && existing.first['syncStatus'] != 'FAILED')
        return;
      final now = DateTime.now().toUtc().toIso8601String();
      await upsertRow(tx, 'local_contributions', {
        'localContributionId': id,
        'userId': owner,
        'type': type,
        'sourceLocalJourneyId': journeyRef,
        'payload': jsonEncode(payload),
        'serverStatus': 'DRAFT',
        'syncStatus': 'PENDING',
        'createdAt': now,
        'updatedAt': now,
      }, 'localContributionId');
      await _enqueue(
        tx,
        id,
        owner,
        'POST',
        type == 'ROUTE_SUBMISSION'
            ? '/contributions/routes'
            : '/contributions/places',
        {...payload, '_contributionRef': id},
        journeyRef,
      );
      await tx.update(
        'offline_outbox',
        {
          'state': 'PENDING',
          'lastError': null,
          'body': jsonEncode({...payload, '_contributionRef': id}),
        },
        where: 'operationId = ? AND ownerId = ?',
        whereArgs: [id, owner],
      );
    });
    return id;
  }

  Future<Map<String, dynamic>?> contribution(String id) async {
    final owner = await requireOwner();
    final rows = await (await databaseHelper.database).query(
      'local_contributions',
      where: '(localContributionId = ? OR serverContributionId = ?) AND userId = ?',
      whereArgs: [id, id, owner],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final snapshot = await read(
      '/contributions/${row['localContributionId']}',
      owner: owner,
    );
    return {
      ...Map<String, dynamic>.from(jsonDecode(row['payload'] as String) as Map),
      if (snapshot is Map) ...Map<String, dynamic>.from(snapshot),
      'contributionId':
          row['serverContributionId'] ?? row['localContributionId'],
      'userId': owner,
      'type': row['type'],
      'status': row['serverStatus'],
      'offlineSyncStatus': row['syncStatus'],
    };
  }

  Future<void> _adoptLegacyContributions(Database db, String owner) async {
    final rows = await db.rawQuery(
      "SELECT c.* FROM local_contributions c JOIN sync_queue s ON s.entityId = c.localContributionId "
      "WHERE c.userId = ? AND s.status = 'PENDING' AND c.syncStatus = 'PENDING' AND c.type IN ('ROUTE_SUBMISSION','PLACE_SUGGESTION')",
      [owner],
    );
    if (rows.isEmpty) return;
    await db.transaction((tx) async {
      for (final row in rows) {
        final id = row['localContributionId'] as String;
        final payload = Map<String, dynamic>.from(
          jsonDecode(row['payload'] as String) as Map,
        );
        payload['clientOperationId'] ??= id;
        await _enqueue(
          tx,
          id,
          owner,
          'POST',
          row['type'] == 'ROUTE_SUBMISSION'
              ? '/contributions/routes'
              : '/contributions/places',
          {...payload, '_contributionRef': id},
          row['sourceLocalJourneyId'] as String?,
        );
      }
    });
  }

  Future<void> sync({required Dio trekking, required Dio checkin}) async {
    if (_syncing != null) return _syncing!;
    _syncing = _flush(trekking, checkin);
    try {
      await _syncing;
    } finally {
      _syncing = null;
    }
  }

  Future<void> _flush(Dio trekking, Dio checkin) async {
    final owner = await ownerProvider();
    if (owner == null) return;
    final db = await databaseHelper.database;
    await _adoptLegacyContributions(db, owner);
    // Retry receipts rejected by the old mock milestone provider once after upgrade.
    // The backend still validates each saved GPS receipt against the real catalog.
    await db.transaction((tx) async {
      const migration = '/migrations/checkin-http-provider-v1';
      if (await _read(tx, migration, owner) != null) return;
      final rejected = await tx.query(
        'offline_outbox',
        where: "ownerId = ? AND path = '/checkins' AND state = 'FAILED'",
        whereArgs: [owner],
      );
      for (final row in rejected) {
        final message = row['lastError']?.toString() ?? '';
        if (!message.contains('Milestone') ||
            !message.contains('không tồn tại')) {
          continue;
        }
        await tx.update(
          'offline_outbox',
          {'state': 'PENDING', 'lastError': null},
          where: 'operationId = ? AND ownerId = ?',
          whereArgs: [row['operationId'], owner],
        );
        await tx.update(
          'offline_checkins',
          {'syncStatus': 'PENDING'},
          where: 'localCheckinId = ? AND userId = ?',
          whereArgs: [row['operationId'], owner],
        );
      }
      await _write(tx, migration, true, owner);
    });
    final operations = await db.query(
      'offline_outbox',
      where: "ownerId = ? AND state = 'PENDING'",
      whereArgs: [owner],
      orderBy: 'createdAt ASC, rowid ASC',
    );
    for (final op in operations) {
      if (await ownerProvider() != owner) return;
      final ref = op['journeyRef'] as String?;
      final body = Map<String, dynamic>.from(
        jsonDecode(op['body'] as String) as Map,
      );
      final previousStatus = body.remove('_previousStatus');
      final markerRef = body.remove('_markerRef') as String?;
      final contributionRef = body.remove('_contributionRef') as String?;
      var path = op['path'] as String;
      if (ref != null && path != '/journeys') {
        final row = await _journeyRow(db, ref, owner);
        final serverId = row['serverJourneyId'];
        if (serverId == null) continue; // Wait for this journey without blocking unrelated contributions.
        path = path.replaceFirst('@journey', serverId.toString());
        if (path == '/checkins') body['journeyId'] = serverId;
        if (path == '/contributions/routes') body['sourceJourneyId'] = serverId;
      }
      if (path.contains('@marker')) {
        final rows = await db.query(
          'local_journey_markers',
          where: 'localMarkerId = ? AND userId = ?',
          whereArgs: [markerRef, owner],
        );
        if (rows.isEmpty || rows.first['serverMarkerId'] == null) return;
        path = path.replaceFirst(
          '@marker',
          rows.first['serverMarkerId'].toString(),
        );
      }
      final dio =
          path.startsWith('/journeys') || path.startsWith('/contributions')
          ? trekking
          : checkin;
      try {
        if (markerRef != null && op['method'] != 'DELETE') {
          final media = await db.query(
            'local_marker_media',
            where: 'localMarkerId = ?',
            whereArgs: [markerRef],
            orderBy: 'createdAt ASC',
          );
          final images = <String>[];
          for (final file in media) {
            var url = file['remoteUrl'] as String?;
            if (url == null || url.isEmpty) {
              final path = file['localPath'] as String;
              url = markerImageUploader != null
                  ? await markerImageUploader!(path, trekking)
                  : await TrekkingUploadService(apiClient: trekking)
                        .uploadImage(path, 'JOURNEY_MARKER');
              await db.update(
                'local_marker_media',
                {'remoteUrl': url, 'uploadStatus': 'UPLOADED'},
                where: 'localMarkerMediaId = ?',
                whereArgs: [file['localMarkerMediaId']],
              );
            }
            images.add(url);
          }
          if (await ownerProvider() != owner) return;
          body['images'] = images;
        }
        if (path == '/contributions/routes' && body['markerIds'] is List) {
          final markerIds = <String>[];
          for (final id in body['markerIds'] as List) {
            final markers = await db.query(
              'local_journey_markers',
              where: '(localMarkerId = ? OR serverMarkerId = ?) AND userId = ?',
              whereArgs: [id, id, owner],
            );
            if (markers.isNotEmpty && markers.first['serverMarkerId'] == null)
              return;
            markerIds.add(
              markers.isEmpty
                  ? id.toString()
                  : markers.first['serverMarkerId'].toString(),
            );
          }
          body['markerIds'] = markerIds;
        }
        Response<dynamic>? replay;
        if ((op['attempts'] as int) > 0 &&
            RegExp(r'^/journeys/[^/]+/(start|pause|resume|complete|cancel)$')
                .hasMatch(path)) {
          const targets = {
            'start': 'ACTIVE',
            'pause': 'PAUSED',
            'resume': 'ACTIVE',
            'complete': 'COMPLETED',
            'cancel': 'CANCELLED',
          };
          final current = await dio.get(
            path.substring(0, path.lastIndexOf('/')),
            options: Options(extra: {'offlineOwner': owner}),
          );
          if (current.data['data']['status'] == targets[path.split('/').last])
            replay = current;
        }
        final response =
            replay ??
            await dio.request(
              path,
              data: body,
              options: Options(
                method: op['method'] as String,
                headers: {'Idempotency-Key': op['operationId']},
                extra: {'offlineOwner': owner},
              ),
            );
        final result = response.data is Map ? response.data['data'] : null;
        await db.transaction((tx) async {
          if (contributionRef != null) {
            final json = Map<String, dynamic>.from(result as Map);
            await tx.update(
              'local_contributions',
              {
                'serverContributionId':
                    json['routeSubmissionId'] ??
                    json['placeSuggestionId'] ??
                    json['contributionId'] ??
                    json['_id'] ??
                    json['id'],
                'serverStatus': json['status'],
                'syncStatus': 'SYNCED',
                'lastSyncedAt': DateTime.now().toUtc().toIso8601String(),
              },
              where: 'localContributionId = ? AND userId = ?',
              whereArgs: [contributionRef, owner],
            );
            await _write(tx, '/contributions/$contributionRef', json, owner);
            await tx.delete(
              'sync_queue',
              where: 'entityId = ? AND entityType IN (?,?)',
              whereArgs: [
                contributionRef,
                'ROUTE_SUBMISSION',
                'PLACE_SUGGESTION',
              ],
            );
          } else if (path == '/journeys') {
            final json = Map<String, dynamic>.from(result as Map);
            final old = Map<String, dynamic>.from(
              await _read(tx, '/journeys/$ref', owner) as Map,
            );
            final later = await tx.query(
              'offline_outbox',
              where: "ownerId = ? AND journeyRef = ? AND operationId != ? AND state = 'PENDING'",
              whereArgs: [owner, ref, op['operationId']],
            );
            await _saveJourney(
              tx,
              {
                ...old,
                ...json,
                if (later.isNotEmpty) 'status': old['status'],
                'offlineSyncStatus': later.isEmpty ? 'SYNCED' : 'PENDING',
                'serverJourneyId': json['journeyId'] ?? json['_id'],
              },
              owner,
              localId: ref,
            );
          } else if (path.contains('/markers') && markerRef != null) {
            if (op['method'] == 'DELETE') {
              await tx.delete(
                'local_marker_media',
                where: 'localMarkerId = ?',
                whereArgs: [markerRef],
              );
              await tx.delete(
                'local_journey_markers',
                where: 'localMarkerId = ? AND userId = ?',
                whereArgs: [markerRef, owner],
              );
            } else {
              final later = await tx.query(
                'offline_outbox',
                where: "ownerId = ? AND operationId != ? AND state = 'PENDING' AND body LIKE ?",
                whereArgs: [
                  owner,
                  op['operationId'],
                  '%"_markerRef":"$markerRef"%',
                ],
              );
              await tx.update(
                'local_journey_markers',
                {
                  'serverMarkerId': result['journeyMarkerId'] ?? result['_id'],
                  if (later.isEmpty) 'syncStatus': 'SYNCED',
                },
                where: 'localMarkerId = ? AND userId = ?',
                whereArgs: [markerRef, owner],
              );
            }
          } else if (path.startsWith('/journeys/')) {
            final old = Map<String, dynamic>.from(
              await _read(tx, '/journeys/$ref', owner) as Map,
            );
            final later = await tx.query(
              'offline_outbox',
              where: "ownerId = ? AND journeyRef = ? AND operationId != ? AND state = 'PENDING'",
              whereArgs: [owner, ref, op['operationId']],
            );
            await _saveJourney(
              tx,
              {
                ...old,
                if (result is Map) ...Map<String, dynamic>.from(result),
                if (later.isNotEmpty) 'status': old['status'],
                'offlineSyncStatus': later.isEmpty ? 'SYNCED' : 'PENDING',
              },
              owner,
              localId: ref,
            );
          } else if (path == '/checkins') {
            await _write(tx, '/checkins/${op['operationId']}', result, owner);
            await tx.update(
              'offline_checkins',
              {
                'serverCheckinId':
                    result['milestoneCheckinId'] ??
                    result['checkinId'] ??
                    result['_id'],
                'verificationStatus': result['verification']?['status'],
                'syncStatus': 'SYNCED',
              },
              where: 'localCheckinId = ? AND userId = ?',
              whereArgs: [op['operationId'], owner],
            );
          }
          await tx.delete(
            'offline_outbox',
            where: 'operationId = ?',
            whereArgs: [op['operationId']],
          );
          if (path.startsWith('/visits/provinces/me/')) {
            final provinces = await _read(tx, '/visits/provinces/me', owner);
            if (provinces is List)
              await _projectProvinces(tx, provinces, owner);
          }
        });
        _changes.add(owner);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) return;
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403)
          rethrow;
        final retryable = canUseCache(e) || e.response?.statusCode == 429;
        final error = e.response?.data is Map
            ? (e.response!.data['error']?['message'] ??
                      e.response!.data['message'] ??
                      'Backend từ chối đồng bộ.')
                  .toString()
            : e.message;
        await db.update(
          'offline_outbox',
          {
            'state': retryable ? 'PENDING' : 'FAILED',
            'attempts': (op['attempts'] as int) + 1,
            'lastError': error,
          },
          where: 'operationId = ?',
          whereArgs: [op['operationId']],
        );
        if (!retryable && contributionRef != null) {
          await db.update(
            'local_contributions',
            {'syncStatus': 'FAILED'},
            where: 'localContributionId = ? AND userId = ?',
            whereArgs: [contributionRef, owner],
          );
        } else if (!retryable && markerRef != null) {
          await db.update(
            'local_journey_markers',
            {'syncStatus': 'FAILED'},
            where: 'localMarkerId = ? AND userId = ?',
            whereArgs: [markerRef, owner],
          );
        } else if (!retryable && ref != null && path.startsWith('/journeys')) {
          final cached = Map<String, dynamic>.from(
            await _read(db, '/journeys/$ref', owner) as Map,
          );
          await _saveJourney(
            db,
            {
              ...cached,
              'offlineSyncStatus': 'FAILED',
              'syncError': error,
              if (previousStatus != null) 'status': previousStatus,
            },
            owner,
            localId: ref,
          );
        } else if (!retryable && path == '/checkins') {
          await db.update(
            'offline_checkins',
            {'syncStatus': 'FAILED'},
            where: 'localCheckinId = ? AND userId = ?',
            whereArgs: [op['operationId'], owner],
          );
        }
        if (retryable) return;
      }
    }
  }
}
