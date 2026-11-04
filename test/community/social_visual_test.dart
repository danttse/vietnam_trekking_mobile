import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/features/community/data/datasources/community_remote_datasource.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/community_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/social_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/conversation_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_screen.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_messages.dart';

import 'social_test.dart' as fixture;

void main() {
  testWidgets(
    'three Community tabs and chat render at phone width in app dark theme',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final font = FontLoader('FZ Poppins')
        ..addFont(rootBundle.load('assets/fonts/FZ Poppins-Regular.ttf'));
      await tester.runAsync(font.load);
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await tester.runAsync(icons.load);
      final api = fixture.api(fixture.fallback);
      final feed = CommunityViewModel(
        dataSource: CommunityRemoteDataSource(api.dio),
        ownerProvider: () async => fixture.alice,
        realtimeEnabled: false,
        autoLoad: false,
      );
      final inbox = SocialViewModel(api: api, realtime: false, autoLoad: false);
      final chat = ConversationViewModel(
        id: fixture.chatId,
        api: api,
        realtime: false,
        autoLoad: false,
      );
      addTearDown(feed.dispose);
      addTearDown(inbox.dispose);
      addTearDown(chat.dispose);
      await tester.runAsync(() async {
        await feed.loadPosts();
        await inbox.load();
        await chat.load();
      });
      final key = GlobalKey();
      Widget app(Widget child) => RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
      Future<void> save(String name) async {
        final dir = Platform.environment['COMMUNITY_VISUAL_QA_DIR'];
        if (dir == null || dir.isEmpty) return;
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('$dir/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tester.pumpWidget(
        app(
          CommunityScreen(
            viewModel: feed,
            socialViewModel: inbox,
            socialApi: api,
            socialRealtimeEnabled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/img_app_logo_ver2.png'),
          key.currentContext!,
        ),
      );
      await tester.pump();
      expect(find.text('Hành trình'), findsNothing);
      await tester.tap(find.text('Tin nhắn').first);
      await tester.pumpAndSettle();
      expect(find.text('Minh'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await save('community-messages');
      await tester.tap(find.text('Cá nhân').first);
      await tester.pumpAndSettle();
      expect(find.text('QR của tôi'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await save('community-personal');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        app(
          ConversationScreen(conversationId: fixture.chatId, viewModel: chat),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tin nhắn 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await save('community-chat');
    },
  );
}
