import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton quản lý SQLite database cho TrekVN offline-first.
class DatabaseHelper {
  static const String _dbName = 'trekvn_local.db';
  static const int _dbVersion = 4;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;
  Future<Database>? _opening;

  /// Isolated database for SQLite migration/integration tests.
  DatabaseHelper.forTesting(Database database) : _db = database;

  static Future<DatabaseHelper> openForTesting(String path) async {
    final helper = DatabaseHelper._internal();
    helper._db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: helper._onConfigure,
      onCreate: helper._onCreate,
      onUpgrade: helper._onUpgrade,
      singleInstance: false,
    );
    return helper;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    try {
      _db = await (_opening ??= _initDatabase());
      return _db!;
    } finally {
      _opening = null;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Bật foreign key enforcement
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
    await _migrateV3toV4(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateV1toV2(db);
    }
    if (oldVersion < 3) {
      await _migrateV2toV3(db);
    }
    if (oldVersion < 4) await _migrateV3toV4(db);
    await _createIndexes(db);
  }

  /// Migration v1 → v2:
  /// Thêm các cột gamification vào bảng local_user.
  Future<void> _migrateV1toV2(Database db) async {
    for (final definition in [
      'currentRankCode TEXT',
      'currentRankName TEXT',
      'currentRankLevel INTEGER',
      'totalXp INTEGER NOT NULL DEFAULT 0',
      'nextRankCode TEXT',
      'nextRankXp INTEGER',
      'rankUpdatedAt TEXT',
    ]) {
      await _addColumn(db, 'local_user', definition);
    }
  }

  Future<void> _addColumn(Database db, String table, String definition) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    if (!columns.any((row) => row['name'] == definition.split(' ').first)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $definition');
    }
  }

  Future<void> _migrateV2toV3(Database db) async {
    for (final d in [
      'scope TEXT NOT NULL DEFAULT "ROUTE"',
      'waypointCount INTEGER DEFAULT 0',
    ]) {
      await _addColumn(db, 'downloaded_maps', d);
    }
    for (final d in [
      'elevationMeters INTEGER',
      'imageMapUrl TEXT',
      'offlineMapAvailable INTEGER DEFAULT 0',
      'offlineMapVersion INTEGER',
      'offlineMapSizeBytes INTEGER',
    ]) {
      await _addColumn(db, 'cached_places', d);
    }
    for (final d in ['note TEXT', 'participantCount INTEGER DEFAULT 1']) {
      await _addColumn(db, 'local_journeys', d);
    }
  }

  Future<void> _migrateV3toV4(Database db) async {
    await _addColumn(db, 'local_journeys', 'plannedEndAt TEXT');
    final visitColumns = await db.rawQuery(
      'PRAGMA table_info(visited_provinces)',
    );
    if (!visitColumns.any((row) => row['name'] == 'ownerId')) {
      await db.execute(
        'ALTER TABLE visited_provinces RENAME TO visited_provinces_v3',
      );
      await db.execute(
        '''CREATE TABLE visited_provinces (
        ownerId TEXT NOT NULL, provinceId TEXT NOT NULL, name TEXT NOT NULL,
        firstVisitedAt TEXT, lastVisitedAt TEXT, visitCount INTEGER DEFAULT 1,
        source TEXT, syncStatus TEXT DEFAULT 'SYNCED', updatedAt TEXT,
        PRIMARY KEY(ownerId, provinceId), FOREIGN KEY(provinceId) REFERENCES cached_provinces(provinceId))''',
      );
      // Old rows contain no account identity. Preserve them without exposing
      // them to whichever user happens to sign in after the upgrade.
      await db.execute(
        "INSERT INTO visited_provinces SELECT '', provinceId, name, firstVisitedAt, lastVisitedAt, visitCount, source, syncStatus, updatedAt FROM visited_provinces_v3",
      );
      await db.execute('DROP TABLE visited_provinces_v3');
    }
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_visited_owner ON visited_provinces(ownerId, lastVisitedAt)',
    );
    await db.execute('''CREATE TABLE IF NOT EXISTS offline_snapshots (
      ownerId TEXT NOT NULL DEFAULT '', resource TEXT NOT NULL, payload TEXT NOT NULL,
      updatedAt TEXT NOT NULL, PRIMARY KEY(ownerId, resource))''');
    await db.execute('''CREATE TABLE IF NOT EXISTS offline_outbox (
      operationId TEXT PRIMARY KEY, ownerId TEXT NOT NULL, method TEXT NOT NULL,
      path TEXT NOT NULL, body TEXT NOT NULL, journeyRef TEXT,
      state TEXT NOT NULL DEFAULT 'PENDING', attempts INTEGER NOT NULL DEFAULT 0,
      lastError TEXT, createdAt TEXT NOT NULL)''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_offline_outbox_owner ON offline_outbox(ownerId, state, createdAt)',
    );
  }

  // ---------------------------------------------------------------------------
  // TABLE CREATION
  // ---------------------------------------------------------------------------

  Future<void> _createTables(Database db) async {
    final batch = db.batch();

    // ------ LOCAL IDENTITY ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS local_user (
        userId            TEXT PRIMARY KEY,
        displayName       TEXT,
        avatarUrl         TEXT,
        email             TEXT,
        currentRankCode   TEXT,
        currentRankName   TEXT,
        currentRankLevel  INTEGER,
        totalXp           INTEGER NOT NULL DEFAULT 0,
        nextRankCode      TEXT,
        nextRankXp        INTEGER,
        rankUpdatedAt     TEXT,
        cachedAt          TEXT,
        updatedAt         TEXT
      )
    ''');

    // ------ CACHE ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS cached_provinces (
        provinceId    TEXT PRIMARY KEY,
        code          TEXT,
        name          TEXT NOT NULL,
        region        TEXT,
        mapFeatureId  TEXT,
        cachedAt      TEXT,
        updatedAt     TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS cached_places (
        trekkingPlaceId         TEXT PRIMARY KEY,
        provinceId              TEXT,
        name                    TEXT NOT NULL,
        slug                    TEXT,
        address                 TEXT,
        latitude                REAL,
        longitude               REAL,
        description             TEXT,
        difficulty              TEXT,
        averageDurationMinutes  INTEGER,
        elevationMeters         INTEGER,
        imageUrl                TEXT,
        imageMapUrl             TEXT,
        ratingAverage           REAL,
        ratingCount             INTEGER,
        offlineMapAvailable     INTEGER DEFAULT 0,
        offlineMapVersion       INTEGER,
        offlineMapSizeBytes     INTEGER,
        status                  TEXT,
        cachedAt                TEXT,
        updatedAt               TEXT,
        FOREIGN KEY (provinceId)
          REFERENCES cached_provinces(provinceId)
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS cached_routes (
        trekkingRouteId             TEXT PRIMARY KEY,
        trekkingPlaceId             TEXT NOT NULL,
        name                        TEXT NOT NULL,
        description                 TEXT,
        difficulty                  TEXT,
        distanceMeters              INTEGER,
        estimatedDurationMinutes    INTEGER,
        elevationGain               INTEGER,
        maxElevation                INTEGER,
        startLatitude               REAL,
        startLongitude              REAL,
        endLatitude                 REAL,
        endLongitude                REAL,
        encodedPolyline             TEXT,
        mapVersion                  INTEGER,
        cachedAt                    TEXT,
        updatedAt                   TEXT,
        FOREIGN KEY (trekkingPlaceId)
          REFERENCES cached_places(trekkingPlaceId)
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS cached_milestones (
        milestoneId           TEXT PRIMARY KEY,
        trekkingRouteId       TEXT NOT NULL,
        name                  TEXT NOT NULL,
        description           TEXT,
        type                  TEXT NOT NULL,
        sequenceNumber        INTEGER NOT NULL,
        latitude              REAL NOT NULL,
        longitude             REAL NOT NULL,
        altitude              REAL,
        checkinRadiusMeters   REAL DEFAULT 50,
        required              INTEGER DEFAULT 1,
        imageUrl              TEXT,
        cachedAt              TEXT,
        updatedAt             TEXT,
        FOREIGN KEY (trekkingRouteId)
          REFERENCES cached_routes(trekkingRouteId),
        UNIQUE (trekkingRouteId, sequenceNumber)
      )
    ''');

    // ------ LOCAL JOURNEYS ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS local_journeys (
        localJourneyId    TEXT PRIMARY KEY,
        serverJourneyId   TEXT,
        userId            TEXT NOT NULL,
        trekkingPlaceId   TEXT NOT NULL,
        trekkingRouteId   TEXT NOT NULL,
        provinceId        TEXT,
        name              TEXT NOT NULL,
        status            TEXT NOT NULL DEFAULT 'PLANNED',
        note              TEXT,
        participantCount  INTEGER DEFAULT 1,
        plannedStartAt    TEXT,
        startedAt         TEXT,
        completedAt       TEXT,
        distanceMeters    REAL DEFAULT 0,
        durationSeconds   INTEGER DEFAULT 0,
        elevationGain     REAL DEFAULT 0,
        maxAltitude       REAL,
        checkinCount      INTEGER DEFAULT 0,
        markerCount       INTEGER DEFAULT 0,
        syncStatus        TEXT DEFAULT 'PENDING',
        createdAt         TEXT,
        updatedAt         TEXT,
        FOREIGN KEY (userId)
          REFERENCES local_user(userId),
        FOREIGN KEY (trekkingPlaceId)
          REFERENCES cached_places(trekkingPlaceId),
        FOREIGN KEY (trekkingRouteId)
          REFERENCES cached_routes(trekkingRouteId),
        FOREIGN KEY (provinceId)
          REFERENCES cached_provinces(provinceId)
      )
    ''');

    // ------ GPS TRACK ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS track_points (
        trackPointId      INTEGER PRIMARY KEY AUTOINCREMENT,
        localJourneyId    TEXT NOT NULL,
        latitude          REAL NOT NULL,
        longitude         REAL NOT NULL,
        altitude          REAL,
        accuracy          REAL,
        speed             REAL,
        heading           REAL,
        recordedAt        TEXT NOT NULL,
        FOREIGN KEY (localJourneyId)
          REFERENCES local_journeys(localJourneyId)
      )
    ''');

    // ------ JOURNEY MARKERS ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS local_journey_markers (
        localMarkerId     TEXT PRIMARY KEY,
        serverMarkerId    TEXT,
        localJourneyId    TEXT NOT NULL,
        userId            TEXT NOT NULL,
        name              TEXT NOT NULL,
        type              TEXT NOT NULL DEFAULT 'OTHER',
        note              TEXT,
        latitude          REAL NOT NULL,
        longitude         REAL NOT NULL,
        altitude          REAL,
        accuracyMeters    REAL,
        markedAt          TEXT NOT NULL,
        syncStatus        TEXT DEFAULT 'LOCAL_ONLY',
        createdAt         TEXT NOT NULL,
        updatedAt         TEXT,
        FOREIGN KEY (localJourneyId)
          REFERENCES local_journeys(localJourneyId),
        FOREIGN KEY (userId)
          REFERENCES local_user(userId)
      )
    ''');

    // ------ MARKER MEDIA ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS local_marker_media (
        localMarkerMediaId  TEXT PRIMARY KEY,
        localMarkerId       TEXT NOT NULL,
        type                TEXT DEFAULT 'IMAGE',
        localPath           TEXT NOT NULL,
        remoteUrl           TEXT,
        fileSizeBytes       INTEGER,
        mimeType            TEXT,
        uploadStatus        TEXT DEFAULT 'LOCAL',
        createdAt           TEXT NOT NULL,
        FOREIGN KEY (localMarkerId)
          REFERENCES local_journey_markers(localMarkerId)
      )
    ''');

    // ------ OFFLINE CHECK-IN ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS offline_checkins (
        localCheckinId          TEXT PRIMARY KEY,
        serverCheckinId         TEXT,
        localJourneyId          TEXT NOT NULL,
        milestoneId             TEXT NOT NULL,
        userId                  TEXT NOT NULL,
        latitude                REAL NOT NULL,
        longitude               REAL NOT NULL,
        accuracyMeters          REAL,
        distanceToTargetMeters  REAL,
        verificationStatus      TEXT,
        checkedAt               TEXT NOT NULL,
        syncStatus              TEXT DEFAULT 'PENDING',
        createdAt               TEXT,
        updatedAt               TEXT,
        FOREIGN KEY (localJourneyId)
          REFERENCES local_journeys(localJourneyId),
        FOREIGN KEY (milestoneId)
          REFERENCES cached_milestones(milestoneId),
        FOREIGN KEY (userId)
          REFERENCES local_user(userId),
        UNIQUE (localJourneyId, milestoneId, userId)
      )
    ''');

    // ------ VISITED PROVINCES ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS visited_provinces (
        provinceId      TEXT PRIMARY KEY,
        name            TEXT NOT NULL,
        firstVisitedAt  TEXT,
        lastVisitedAt   TEXT,
        visitCount      INTEGER DEFAULT 1,
        source          TEXT,
        syncStatus      TEXT DEFAULT 'SYNCED',
        updatedAt       TEXT,
        FOREIGN KEY (provinceId)
          REFERENCES cached_provinces(provinceId)
      )
    ''');

    // ------ DOWNLOADED MAPS ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS downloaded_maps (
        mapId             TEXT PRIMARY KEY,
        scope             TEXT NOT NULL DEFAULT 'ROUTE',
        trekkingPlaceId   TEXT,
        trekkingRouteId   TEXT,
        mapName           TEXT NOT NULL,
        localPath         TEXT NOT NULL,
        mapVersion        INTEGER,
        sizeBytes         INTEGER,
        waypointCount     INTEGER DEFAULT 0,
        minZoom           INTEGER,
        maxZoom           INTEGER,
        minLatitude       REAL,
        minLongitude      REAL,
        maxLatitude       REAL,
        maxLongitude      REAL,
        checksum          TEXT,
        downloadedAt      TEXT,
        lastUsedAt        TEXT,
        status            TEXT DEFAULT 'READY',
        FOREIGN KEY (trekkingPlaceId)
          REFERENCES cached_places(trekkingPlaceId),
        FOREIGN KEY (trekkingRouteId)
          REFERENCES cached_routes(trekkingRouteId)
      )
    ''');

    // ------ SYNC QUEUE ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        syncQueueId       INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType        TEXT NOT NULL,
        entityId          TEXT NOT NULL,
        operation         TEXT NOT NULL,
        payload           TEXT,
        status            TEXT DEFAULT 'PENDING',
        retryCount        INTEGER DEFAULT 0,
        idempotencyKey    TEXT NOT NULL UNIQUE,
        priority          TEXT DEFAULT 'NORMAL',
        nextRetryAt       TEXT,
        scheduledAfter    TEXT,
        payloadSizeBytes  INTEGER,
        createdAt         TEXT NOT NULL,
        lastAttemptAt     TEXT,
        lastError         TEXT
      )
    ''');

    // ------ LOCAL CONTRIBUTIONS ------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS local_contributions (
        localContributionId   TEXT PRIMARY KEY,
        serverContributionId  TEXT,
        userId                TEXT NOT NULL,
        type                  TEXT NOT NULL,
        sourceLocalJourneyId  TEXT,
        sourceServerJourneyId TEXT,
        payload               TEXT NOT NULL,
        serverStatus          TEXT DEFAULT 'DRAFT',
        syncStatus            TEXT DEFAULT 'PENDING',
        adminNote             TEXT,
        resultingEntityId     TEXT,
        createdAt             TEXT,
        updatedAt             TEXT,
        lastSyncedAt          TEXT,
        FOREIGN KEY (userId)
          REFERENCES local_user(userId),
        FOREIGN KEY (sourceLocalJourneyId)
          REFERENCES local_journeys(localJourneyId)
      )
    ''');

    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // INDEX CREATION
  // ---------------------------------------------------------------------------

  Future<void> _createIndexes(Database db) async {
    final batch = db.batch();

    // cached_routes
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_cached_routes_place
      ON cached_routes(trekkingPlaceId)
    ''');

    // cached_milestones
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_cached_milestones_route
      ON cached_milestones(trekkingRouteId)
    ''');

    // local_journeys
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_journeys_user
      ON local_journeys(userId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_journeys_route
      ON local_journeys(trekkingRouteId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_journeys_status
      ON local_journeys(status)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_journeys_sync
      ON local_journeys(syncStatus)
    ''');

    // track_points
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_track_points_journey
      ON track_points(localJourneyId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_track_points_journey_time
      ON track_points(localJourneyId, recordedAt)
    ''');

    // local_journey_markers
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_markers_journey
      ON local_journey_markers(localJourneyId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_markers_user
      ON local_journey_markers(userId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_markers_sync
      ON local_journey_markers(syncStatus)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_markers_journey_time
      ON local_journey_markers(localJourneyId, markedAt)
    ''');

    // local_marker_media
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_media_marker
      ON local_marker_media(localMarkerId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_media_upload_status
      ON local_marker_media(uploadStatus)
    ''');

    // offline_checkins
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkins_journey
      ON offline_checkins(localJourneyId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkins_milestone
      ON offline_checkins(milestoneId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_checkins_sync
      ON offline_checkins(syncStatus)
    ''');

    // downloaded_maps
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_maps_scope
      ON downloaded_maps(scope)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_maps_route
      ON downloaded_maps(trekkingRouteId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_maps_place
      ON downloaded_maps(trekkingPlaceId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_maps_scope_place
      ON downloaded_maps(scope, trekkingPlaceId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_maps_scope_route
      ON downloaded_maps(scope, trekkingRouteId)
    ''');

    // sync_queue
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_status
      ON sync_queue(status)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_entity_type
      ON sync_queue(entityType)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_entity
      ON sync_queue(entityType, entityId)
    ''');

    // local_contributions
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_contributions_user
      ON local_contributions(userId)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_contributions_type
      ON local_contributions(type)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_contributions_server_status
      ON local_contributions(serverStatus)
    ''');
    batch.execute('''
      CREATE INDEX IF NOT EXISTS idx_contributions_sync
      ON local_contributions(syncStatus)
    ''');

    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // UTILITY
  // ---------------------------------------------------------------------------

  /// Xóa toàn bộ dữ liệu (dùng khi logout)
  Future<void> clearAllData() async {
    final db = await database;
    final batch = db.batch();

    // Xóa theo thứ tự phụ thuộc (child trước, parent sau)
    for (final table in _tableDeletionOrder) {
      batch.delete(table);
    }

    await batch.commit(noResult: true);
  }

  static const List<String> _tableDeletionOrder = [
    'offline_outbox',
    'offline_snapshots',
    'local_contributions',
    'sync_queue',
    'downloaded_maps',
    'visited_provinces',
    'offline_checkins',
    'local_marker_media',
    'local_journey_markers',
    'track_points',
    'local_journeys',
    'cached_milestones',
    'cached_routes',
    'cached_places',
    'cached_provinces',
    'local_user',
  ];

  /// Đóng database (dùng khi test hoặc cần reset)
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
