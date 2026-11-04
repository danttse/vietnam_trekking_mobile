import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/comment_item.dart';
import 'package:vietnam_trekking_mobile/features/community/data/models/comment_model.dart';
import 'package:vietnam_trekking_mobile/features/community/data/models/post_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/create_new_post_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/community_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/views/create_new_post_creen.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_screen.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_action_dialogs.dart';

import 'community_api_test.dart' show source, post, page, comment;

Widget app(Widget child) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  testWidgets('composer edits privacy and saves the original server post', (
    tester,
  ) async {
    Map? body;
    final existing = PostModel.fromJson({...post('p'), 'images': <String>[]});
    final vm = CreateNewPostViewModel(
      editingPost: existing,
      dataSource: source((r) {
        body = r.data as Map;
        return {
          'data': {
            ...post('p'),
            ...Map<String, dynamic>.from(body!),
            'images': <String>[],
          },
        };
      }),
    );
    addTearDown(vm.dispose);
    await tester.pumpWidget(app(CreateNewPostCreen(viewModel: vm)));
    await tester.tap(find.text('Chỉ mình tôi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nội dung sau sửa');
    await tester.ensureVisible(find.text('Lưu thay đổi'));
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();
    expect(body?['visibility'], 'PRIVATE');
    expect(body?['content'], 'Nội dung sau sửa');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'post deletion requires confirmation and cancelling never calls API',
    (tester) async {
      var deletes = 0;
      final vm = CommunityViewModel(
        dataSource: source((r) {
          if (r.method == 'DELETE') {
            deletes++;
            return {'success': true};
          }
          return page(
            deletes == 0
                ? [
                    {...post('p'), 'images': <String>[]},
                  ]
                : [],
          );
        }),
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
      );
      addTearDown(vm.dispose);
      await tester.runAsync(() => vm.loadPosts());
      await tester.pumpWidget(app(CommunityScreen(viewModel: vm)));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa bài viết'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(deletes, 0);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa bài viết'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      expect(deletes, 1);
      expect(vm.posts, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'deleted comments expose neither reactions nor edit/delete/report controls',
    (tester) async {
      final c = CommentModel.fromJson(comment('c', deleted: true));
      await tester.pumpWidget(
        app(
          Scaffold(
            body: CommentItem(comment: c, onEdit: () {}, onDelete: () {}),
          ),
        ),
      );
      expect(find.text('Bình luận đã bị xóa'), findsOneWidget);
      expect(find.text('Thích'), findsNothing);
      expect(find.text('Phản hồi'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    },
  );

  testWidgets('failed edit stays in its dialog and keeps the typed draft', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Scaffold(
          body: EditCommunityCommentDialog(
            content: 'before',
            onSave: (_) async => 'Không thể lưu bình luận.',
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'draft after');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể lưu bình luận.'), findsOneWidget);
    expect(find.text('draft after'), findsOneWidget);
  });

  testWidgets('composer fits a small display with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = CreateNewPostViewModel(
      dataSource: source((_) => {'data': post('p')}),
    );
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      app(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(1.6),
          ),
          child: CreateNewPostCreen(viewModel: vm),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Đăng bài viết'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
