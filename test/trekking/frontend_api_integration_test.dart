import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/user_api_service.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/profile_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/suggest_place_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/milestone_model.dart';

class FixtureAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions) handler;
  FixtureAdapter(this.handler);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = handler(options);
    final status = body.remove('_httpStatus') as int? ?? 200;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio client(Map<String, dynamic> Function(RequestOptions) handler) =>
    Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'))
      ..httpClientAdapter = FixtureAdapter(handler);

Map<String, dynamic> provinces() => {
  'success': true,
  'data': {
    'summary': {'totalProvinces': 34, 'visitedCount': 2},
    'provinces': [
      {'provinceId': 'province-object-id', 'name': 'Lâm Đồng'},
    ],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('journey and milestone parse the persisted backend contract', () {
    final journey = JourneyModel.fromJson({
      'journeyId': 'server-journey',
      'clientJourneyId': 'local-journey',
      'userId': 'user-1',
      'trekkingRouteId': 'route-1',
      'trekkingPlaceId': 'place-1',
      'name': 'Trip',
      'status': 'PAUSED',
      'participantCount': 3,
      'statistics': {
        'distanceMeters': 1250.5,
        'durationSeconds': 3600,
        'elevationGain': 350.5,
      },
      'checkinCount': 2,
      'markerCount': 1,
    });
    expect(journey.status, JourneyStatus.paused);
    expect(journey.clientJourneyId, 'local-journey');
    expect(journey.userId, 'user-1');
    expect(journey.trekkingRouteId, 'route-1');
    expect(journey.distanceMeters, 1250.5);
    expect(journey.durationSeconds, 3600);
    expect(journey.checkinCount, 2);
    final milestone = MilestoneModel.fromJson({
      'milestoneId': 'm-1',
      'trekkingRouteId': 'route-1',
      'location': {
        'type': 'Point',
        'coordinates': [108.4, 12.1],
      },
      'checkinRadiusMeters': 35,
      'altitude': 1234.5,
    });
    expect(milestone.latitude, 12.1);
    expect(milestone.longitude, 108.4);
    expect(milestone.copyWith(isCheckedIn: true).checkinRadiusMeters, 35);
    expect(milestone.copyWith(isCheckedIn: true).altitude, 1234.5);
  });

  test(
    'profile loads server identity, stats and only server-earned badges',
    () async {
      final api = UserApiService(cacheEnabled: false, 
        authClient: client(
          (r) => {
            'data': switch (r.path) {
              '/users/me' => {
                'userId': 'u',
                'displayName': 'Server user',
                'bio': 'Actual bio',
                'email': 'u@example.com',
                'createdAt': '2026-01-01T00:00:00Z',
              },
              '/gamification/me' => {
                'rank': {'code': 'NEWBIE', 'name': 'Newbie', 'level': 1},
                'totalXp': 100,
                'nextRank': {
                  'code': 'HIKER',
                  'name': 'Hiker',
                  'level': 2,
                  'minXp': 500,
                },
              },
              '/gamification/me/progress' => {
                'currentRank': {'code': 'NEWBIE', 'name': 'Newbie', 'level': 1},
                'nextRank': {'code': 'HIKER', 'name': 'Hiker', 'level': 2},
                'requirements': {
                  'xp': {'current': 100, 'required': 500, 'completed': false},
                },
                'overallProgressPercent': 20,
              },
              _ => throw StateError('Unexpected endpoint ${r.path}'),
            },
          },
        ),
        checkinClient: client((r) => provinces()),
        trekkingClient: client(
          (r) => switch (r.path) {
            '/journeys/statistics' => {
              'data': {
                'totalDistanceMeters': 42500,
                'totalJourneys': 3,
                'totalDurationSeconds': 172800,
              },
            },
            '/badges' => {
              'data': {
                'items': [
                  {'badgeId': 'b1', 'name': 'Earned'},
                  {'badgeId': 'b2', 'name': 'Locked'},
                ],
                'total': 2,
              },
            },
            '/badges/me' => {
              'data': [
                {
                  'badgeId': {'badgeId': 'b1'},
                  'earnedAt': '2026-10-01T00:00:00Z',
                },
              ],
            },
            _ => throw StateError('Unexpected endpoint ${r.path}'),
          },
        ),
      );
      final vm = ProfileViewModel(api: api);
      expect(vm.profile.id, isEmpty);
      await vm.load();
      expect(vm.error, isNull);
      expect(vm.profile.name, 'Server user');
      expect(vm.profile.completedTrips, 3);
      expect(vm.profile.totalDays, 2);
      expect(vm.profile.visitedProvinces, 2);
      expect(vm.profile.isPro, isFalse);
      expect(vm.rankProfile!.rank.name, 'Newbie');
      expect(vm.rankProfile!.totalXp, 100);
      expect(vm.rankError, isNull);
      expect(
        vm.profile.achievements.where((b) => b.isUnlocked).map((b) => b.id),
        ['b1'],
      );
      vm.dispose();
    },
  );

  test('suggestion uses server province ID, GeoJSON and stable operation ID on retry', () async {
    final requests = <Map<String, dynamic>>[];
    var fail = true;
    final api = UserApiService(cacheEnabled: false, 
      authClient: client((r) => {'data': {}}),
      checkinClient: client((r) => provinces()),
      trekkingClient: client((r) {
        expect(r.method, 'POST');
        expect(r.path, '/contributions/places');
        requests.add(Map<String, dynamic>.from(r.data as Map));
        if (fail) {
          return {
            '_httpStatus': 503,
            'error': {'message': 'Unavailable'},
          };
        }
        return {
          'data': {'status': 'PENDING_REVIEW'},
        };
      }),
    );
    final vm = SuggestPlaceViewModel(api: api);
    await vm.loadProvinces();
    vm.placeNameController.text = 'New mountain';
    vm.descriptionController.text = 'A detailed description for admin review';
    vm.gpsController.text = '12.1, 108.4';
    expect(await vm.submit(), isFalse);
    expect(vm.error, isNotNull);
    fail = false;
    expect(await vm.submit(), isTrue);
    expect(requests.first['provinceId'], 'province-object-id');
    expect(requests.first['location']['coordinates'], [108.4, 12.1]);
    expect(requests.first['difficulty'], 'HARD');
    expect(
      requests.first['clientOperationId'],
      requests.last['clientOperationId'],
    );
    vm.gpsController.text = '999, 108';
    expect(await vm.submit(), isFalse);
    expect(requests.length, 2);
    vm.dispose();
  });

  test('bio calls backend and propagates a rejected save', () async {
    final api = UserApiService(cacheEnabled: false, 
      authClient: client((r) {
        expect(r.method, 'PATCH');
        expect(r.path, '/users/me/bio');
        expect(r.data, {'bio': ''});
        return {'_httpStatus': 403, 'message': 'Forbidden'};
      }),
    );
    await expectLater(api.updateBio(''), throwsA(isA<DioException>()));
  });
}
