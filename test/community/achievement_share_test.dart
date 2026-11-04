import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/features/community/data/datasources/community_attachment_datasource.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/create_new_post_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/community/views/create_new_post_creen.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_share.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/profile/data/models/badge_model.dart';
import 'package:vietnam_trekking_mobile/features/profile/views/badge_detail_screen.dart';

import 'community_api_test.dart' show source, post;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline journey cannot open a community draft with a local ID', (
    tester,
  ) async {
    final journey = JourneyModel.fromJson({
      'journeyId': 'local-trip',
      'name': 'Hành trình ngoại tuyến',
      'status': 'COMPLETED',
      'offlineSyncStatus': 'PENDING',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => shareJourneyToCommunity(context, journey),
              child: const Text('Chia sẻ'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Chia sẻ'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateNewPostCreen), findsNothing);
    expect(
      find.text('Vui lòng đồng bộ hành trình trước khi chia sẻ lên cộng đồng.'),
      findsOneWidget,
    );
  });

  test(
    'badge draft posts edited content with BADGE_SHARE to community API',
    () async {
      final vm = CreateNewPostViewModel(
        initialContent: 'Đã đạt huy hiệu đầu tiên!',
        initialType: 'BADGE_SHARE',
        dataSource: source((request) {
          expect(request.method, 'POST');
          expect(request.path, '/posts');
          expect(request.data['type'], 'BADGE_SHARE');
          expect(request.data['content'], 'Thành tích của tôi');
          expect(request.data.containsKey('journeyId'), isFalse);
          return {
            'data': {...post('badge-post'), ...request.data as Map},
          };
        }),
      );
      addTearDown(vm.dispose);
      expect(vm.contentController.text, 'Đã đạt huy hiệu đầu tiên!');
      vm.contentController.text = 'Thành tích của tôi';
      expect((await vm.submitPost())?.type, 'BADGE_SHARE');
    },
  );

  test(
    'completed journey draft submits linked server journey and can remove it',
    () async {
      var calls = 0;
      final vm = CreateNewPostViewModel(
        initialContent: 'Hoàn thành Fansipan!',
        initialJourney: const CommunityAttachment(
          id: '1234567890abcdef12345678',
          name: 'Fansipan',
          placeId: 'abcdef1234567890abcdef12',
        ),
        dataSource: source((request) {
          expect(request.data['type'], calls == 0 ? 'JOURNEY_SHARE' : 'NORMAL');
          expect(
            request.data['journeyId'],
            calls == 0 ? '1234567890abcdef12345678' : null,
          );
          calls++;
          return {
            'data': {...post('journey-post'), ...request.data as Map},
          };
        }),
      );
      addTearDown(vm.dispose);
      expect(await vm.submitPost(), isNotNull);
      vm.selectJourney(null);
      expect(await vm.submitPost(), isNotNull);
      expect(calls, 2);
    },
  );

  for (final width in [320.0, 360.0]) {
    testWidgets(
      'badge labels fit width $width with large text and share opens draft',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final badges = [
          BadgeModel(
            id: '1',
            name: 'ĐIỂM ĐẾN ĐẦU TIÊN',
            description: 'Khám phá địa điểm trekking đầu tiên.',
          ),
          BadgeModel(id: '2', name: 'BƯỚC CHÂN ĐẦU TIÊN'),
          BadgeModel(id: '3', name: 'HÀNH TRÌNH ĐẦU TIÊN'),
          BadgeModel(id: '4', name: 'NHÀ KHÁM PHÁ'),
        ];
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: BadgeDetailScreen(badge: badges.first, allBadges: badges),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Xem tất cả'));
        await tester.tap(find.text('Xem tất cả'));
        await tester.pumpAndSettle();
        expect(find.text('Tất cả huy hiệu'), findsOneWidget);
        final badgeTile = find.widgetWithText(ListTile, 'NHÀ KHÁM PHÁ');
        await tester.scrollUntilVisible(
          badgeTile,
          100,
          scrollable: find.descendant(
            of: find.byType(DraggableScrollableSheet),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(
          tester.element(badgeTile),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(badgeTile);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Chia sẻ thành tích'));
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPostCreen), findsOneWidget);
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller!.text, contains('NHÀ KHÁM PHÁ'));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
