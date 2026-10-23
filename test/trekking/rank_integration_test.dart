import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/models/rank_model.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/core/services/user_api_service.dart';
import 'package:vietnam_trekking_mobile/core/widgets/user_avatar.dart';
import 'package:vietnam_trekking_mobile/features/home/widgets/home_profile_button.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/profile_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/profile/views/profile_screen.dart';
import 'package:vietnam_trekking_mobile/features/profile/widgets/rank_widgets.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

import 'frontend_api_integration_test.dart' show client;

const _rank = {'code': 'NEWBIE', 'name': 'Newbie', 'level': 1};
const _next = {'code': 'HIKER', 'name': 'Hiker', 'level': 2};
const _rankProfile = {'rank': _rank, 'totalXp': 600, 'nextRank': _next};
const _progress = {
  'currentRank': _rank,
  'nextRank': _next,
  'overallProgressPercent': 75,
  'requirements': {
    'xp': {'current': 600, 'required': 500, 'completed': true},
    'completedJourneys': {'current': 1, 'required': 2, 'completed': false},
    'visitedProvinces': {'current': 1, 'required': 1, 'completed': true},
    'badges': {'current': 0, 'required': 1, 'completed': false},
    'distanceMeters': {'current': 2500, 'required': 0, 'completed': true},
    'approvedContributions': {'current': 0, 'required': 0, 'completed': true},
  },
};
const _catalog = [
  {
    'code': 'HIKER',
    'name': 'Hiker',
    'level': 2,
    'description': 'Hạng thử nghiệm từ backend',
    'minXp': 500,
    'requirements': {
      'completedJourneys': 2,
      'visitedProvinces': 1,
      'badges': 1,
      'distanceMeters': 12500,
      'approvedContributions': 3,
    },
  },
  {..._rank, 'minXp': 0, 'requirements': {}},
];

UserApiService _api({bool failProgress = false}) => UserApiService(
  cacheEnabled: false,
  authClient: client(
    (request) => switch (request.path) {
      '/users/me' => {
        'data': {
          'userId': 'u',
          'displayName': 'Nguyễn Văn Khoa với tên thật dài',
          'avatarUrl': 'https://fixture.invalid/avatar.jpg',
          'bio': '',
          'createdAt': '2026-10-01T00:00:00Z',
        },
      },
      '/gamification/me' => {'data': _rankProfile},
      '/gamification/me/progress' =>
        failProgress
            ? {'_httpStatus': 503, 'message': 'Unavailable'}
            : {'data': _progress},
      '/gamification/ranks' => {'data': _catalog},
      _ => throw StateError('Unexpected endpoint ${request.path}'),
    },
  ),
  trekkingClient: client(
    (request) => switch (request.path) {
      '/journeys/statistics' => {'data': {}},
      '/badges' => {
        'data': {'items': [], 'total': 0},
      },
      '/badges/me' => {'data': []},
      _ => throw StateError('Unexpected endpoint ${request.path}'),
    },
  ),
  checkinClient: client(
    (_) => {
      'data': {
        'summary': {'visitedCount': 1, 'totalProvinces': 34},
      },
    },
  ),
);

class _DelayedRankApi extends UserApiService {
  final pending = Completer<UserRankProfile>();
  final started = Completer<void>();
  _DelayedRankApi()
    : super(authClient: Dio(), trekkingClient: Dio(), checkinClient: Dio());
  @override
  Future<Map<String, dynamic>> getProfile() async => {
    'userId': 'u',
    'displayName': 'User',
  };
  @override
  Future<UserRankProfile> getRankProfile() {
    started.complete();
    return pending.future;
  }

  @override
  Future<RankProgress> getRankProgress() async =>
      RankProgress.fromJson(_progress);
  @override
  Future<Map<String, dynamic>> getStatistics() async => {};
  @override
  Future<Map<String, dynamic>> getProvinceVisits() async => {};
  @override
  Future<List<Map<String, dynamic>>> getBadges() async => [];
  @override
  Future<List<Map<String, dynamic>>> getEarnedBadges() async => [];
}

Widget _app(Widget home, {bool largeText = false}) => MaterialApp(
  theme: AppTheme.darkTheme,
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(largeText ? 1.4 : 1)),
    child: child!,
  ),
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'uses actual gamification contract; XP alone does not change rank',
    () async {
      final api = _api();
      final profile = await api.getRankProfile();
      final progress = await api.getRankProgress();
      final ranks = await api.getRanks();
      expect(profile.rank.code, 'NEWBIE');
      expect(profile.rank.level, 1);
      expect(profile.totalXp, 600);
      expect(progress.requirements['xp']!.completed, isTrue);
      expect(progress.requirements['completedJourneys']!.completed, isFalse);
      expect(progress.fraction, 0.75);
      expect(ranks.map((rank) => rank.code), ['NEWBIE', 'HIKER']);
      expect(ranks.last.requirements['xp'], 500);
      expect(ranks.last.requirements['distanceMeters'], 12500);
      expect(ranks.last.requirements['approvedContributions'], 3);
    },
  );

  test('progress outage preserves real rank, XP and avatar', () async {
    final vm = ProfileViewModel(api: _api(failProgress: true));
    await vm.load();
    expect(vm.error, isNull);
    expect(vm.rankError, isNotNull);
    expect(vm.rankProfile!.totalXp, 600);
    expect(vm.rankProfile!.rank.name, 'Newbie');
    expect(vm.profile.avatarUrl, 'https://fixture.invalid/avatar.jpg');
    expect(vm.rankProgress, isNull);
    expect(vm.isRankLoading, isFalse);
    vm.dispose();
  });

  test(
    'a rank response arriving after logout cannot restore previous user data',
    () async {
      final api = _DelayedRankApi();
      final vm = ProfileViewModel(api: api);
      final loading = vm.load();
      await api.started.future;
      AuthEventBus().fire(AuthEvent.loggedOut);
      await Future<void>.delayed(Duration.zero);
      api.pending.complete(UserRankProfile.fromJson(_rankProfile));
      await loading;
      expect(vm.profile.id, isEmpty);
      expect(vm.rankProfile, isNull);
      expect(vm.rankProgress, isNull);
      expect(vm.isRankLoading, isFalse);
      vm.dispose();
    },
  );

  testWidgets('Home shows actual rank, level and avatar on a narrow screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 175,
              child: HomeProfileButton(
                name: 'Nguyễn Văn Khoa với tên rất dài',
                avatarUrl: 'https://fixture.invalid/avatar.jpg',
                rank: RankInfo.fromJson(_rank),
                onTap: () {},
              ),
            ),
          ),
        ),
        largeText: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('dài'), findsOneWidget);
    expect(find.textContaining('Level 1'), findsOneWidget);
    expect(
      tester.widget<UserAvatar>(find.byType(UserAvatar)).imageUrl,
      'https://fixture.invalid/avatar.jpg',
    );
    expect(find.text('PHÂN HẠNG'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Profile rank precedes achievements and opens live rank requirements',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = ProfileViewModel(api: _api());
      await tester.runAsync(vm.load);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: _app(const ProfileScreen(), largeText: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Newbie · Level 1'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Profile layout');
      expect(
        tester.getTopLeft(find.byType(RankSummaryCard)).dy,
        lessThan(tester.getTopLeft(find.text('DANH HIỆU CỦA BẠN')).dy),
      );
      await tester.scrollUntilVisible(find.text('Xem chi tiết các hạng'), 250);
      await tester.tap(find.text('Xem chi tiết các hạng'));
      await tester.pumpAndSettle();
      expect(find.text('Hạng và XP'), findsOneWidget);
      expect(find.text('600 XP'), findsOneWidget);
      expect(find.textContaining('Đã đủ XP'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Rank details layout');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('rank-HIKER')),
        250,
      );
      await tester.ensureVisible(find.text('Hiker').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hiker').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Đóng góp được duyệt'), 120);
      expect(find.text('12,5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );

  testWidgets(
    'highest rank has no next milestone or remaining XP requirement',
    (tester) async {
      final profile = UserRankProfile.fromJson({
        'rank': {'code': 'TREK_LEGEND', 'name': 'Trek Legend', 'level': 10},
        'totalXp': 81000,
        'nextRank': null,
      });
      final progress = RankProgress.fromJson({
        'currentRank': {
          'code': 'TREK_LEGEND',
          'name': 'Trek Legend',
          'level': 10,
        },
        'nextRank': null,
        'requirements': {},
        'overallProgressPercent': 100,
      });
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: RankSummaryCard(
              profile: profile,
              progress: progress,
              onRetry: () {},
            ),
          ),
        ),
      );
      expect(find.text('Bạn đã đạt hạng cao nhất!'), findsOneWidget);
      expect(find.text('81.000 XP'), findsOneWidget);
      expect(find.textContaining('Hạng tiếp theo'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
