import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/models/rank_model.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/core/services/user_api_service.dart';
import 'package:vietnam_trekking_mobile/core/services/gamification_event_bus.dart';
import 'package:vietnam_trekking_mobile/core/network/interceptors/gamification_interceptor.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/profile_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/profile/widgets/rank_widgets.dart';
import 'package:vietnam_trekking_mobile/features/profile/widgets/rank_promotion_dialog.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

import 'frontend_api_integration_test.dart' show client;

const newbie = RankInfo(code: 'NEWBIE', name: 'Newbie', level: 1);
const hiker = RankInfo(code: 'HIKER', name: 'Hiker', level: 2);

class ChangingApi extends UserApiService {
  UserRankProfile current = const UserRankProfile(rank: newbie, totalXp: 0);
  List<Map<String, dynamic>> catalog = [];
  List<Map<String, dynamic>> awards = [];
  ChangingApi()
    : super(authClient: Dio(), trekkingClient: Dio(), checkinClient: Dio());
  @override
  Future<Map<String, dynamic>> getProfile() async => {
    'userId': 'user',
    'displayName': 'User',
  };
  @override
  Future<UserRankProfile> getRankProfile() async => current;
  @override
  Future<RankProgress> getRankProgress() async => RankProgress.fromJson({
    'currentRank': {
      'code': current.rank.code,
      'name': current.rank.name,
      'level': current.rank.level,
    },
    'requirements': {},
    'overallProgressPercent': 100,
    'nextRank': null,
  });
  @override
  Future<Map<String, dynamic>> getStatistics() async => {};
  @override
  Future<Map<String, dynamic>> getProvinceVisits() async => {'summary': {}};
  @override
  Future<List<Map<String, dynamic>>> getBadges() async => catalog;
  @override
  Future<List<Map<String, dynamic>>> getEarnedBadges() async => awards;
}

void main() {
  testWidgets('promotion dialog shows rank and closes on continue', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const RankPromotionDialog(
                  profile: UserRankProfile(rank: hiker, totalXp: 500),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Chúc mừng bạn thăng hạng!'), findsOneWidget);
    expect(find.textContaining('Hiker'), findsOneWidget);
    expect(find.text('500 XP'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục khám phá'));
    await tester.pumpAndSettle();
    expect(find.byType(RankPromotionDialog), findsNothing);
  });
  test('only confirmed reward activities request a rank refresh', () async {
    var activities = 0;
    final sub = GamificationEventBus().stream.listen((_) => activities++);
    final dio = client((_) => {'success': true});
    dio.interceptors.add(GamificationInterceptor());
    await dio.post('/checkins');
    await dio.post('/checkins/sync');
    await dio.post('/journeys/journey/complete');
    await dio.get('/checkins');
    await dio.post('/contributions/places');
    await Future<void>.delayed(Duration.zero);
    expect(activities, 3);
    await sub.cancel();
    dio.close();
  });
  test(
    'XP updates quietly; only promotion emits once and resets on logout',
    () async {
      final api = ChangingApi();
      final vm = ProfileViewModel(api: api);
      final updates = <RankUpdate>[];
      final sub = vm.rankUpdates.listen(updates.add);
      await vm.load();
      await Future<void>.delayed(Duration.zero);
      expect(updates, isEmpty);
      api.current = const UserRankProfile(rank: newbie, totalXp: 150);
      await vm.loadRank();
      await Future<void>.delayed(Duration.zero);
      expect(vm.rankProfile!.totalXp, 150);
      expect(updates, isEmpty);
      api.current = const UserRankProfile(rank: hiker, totalXp: 500);
      await vm.loadRank();
      await vm.loadRank();
      await Future<void>.delayed(Duration.zero);
      expect(updates, hasLength(1));
      expect(updates.single.xpEarned, 350);
      expect(updates.single.promoted, isTrue);
      expect(vm.rankProfile!.rank.code, 'HIKER');
      AuthEventBus().fire(AuthEvent.loggedOut);
      await Future<void>.delayed(Duration.zero);
      expect(vm.rankProfile, isNull);
      api.current = const UserRankProfile(rank: newbie, totalXp: 1000);
      await vm.load();
      await Future<void>.delayed(Duration.zero);
      expect(updates, hasLength(1));
      await sub.cancel();
      vm.dispose();
    },
  );

  testWidgets('polling refreshes XP and stops when app monitoring stops', (
    tester,
  ) async {
    final api = ChangingApi();
    final vm = ProfileViewModel(api: api);
    await vm.load();
    vm.startRankUpdates();
    await tester.pump();
    api.current = const UserRankProfile(rank: newbie, totalXp: 150);
    await tester.pump(const Duration(seconds: 15));
    expect(vm.rankProfile!.totalXp, 150);
    vm.stopRankUpdates();
    api.current = const UserRankProfile(rank: newbie, totalXp: 300);
    await tester.pump(const Duration(seconds: 30));
    expect(vm.rankProfile!.totalXp, 150);
    vm.dispose();
  });

  testWidgets(
    'verified activity refreshes earned badges as well as rank, preserving inactive earned definitions',
    (tester) async {
      final api = ChangingApi();
      final badge = {
        'id': 'b1',
        'name': 'Hành trình đầu tiên',
        'condition': {'type': 'JOURNEY_COUNT', 'value': 1},
      };
      api.catalog = [badge];
      final vm = ProfileViewModel(api: api);
      await vm.load();
      expect(vm.profile.achievements.single.isUnlocked, false);
      vm.startRankUpdates();
      await tester.pump();
      api.catalog = []; // an earned badge was disabled by admin
      api.awards = [
        {'badgeId': badge, 'earnedAt': '2026-10-11T00:00:00Z'},
      ];
      GamificationEventBus().activityCompleted();
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(vm.profile.achievements.single.isUnlocked, true);
      expect(vm.profile.achievements.single.progressUnit, 'Hành trình');
      expect(vm.profile.achievements.single.achievedDate, '11/10/2026');
      vm.dispose();
    },
  );

  testWidgets('all ten rank emblems match admin emoji mapping', (tester) async {
    for (final entry in RankInfo.icons.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: RankEmblem(
            rank: RankInfo(code: entry.key, name: entry.key, level: 1),
          ),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
