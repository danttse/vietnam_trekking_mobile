import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/features/auth/views/login_screen.dart';
import 'package:vietnam_trekking_mobile/features/auth/views/register_screen.dart';
import 'package:vietnam_trekking_mobile/features/auth/views/forgot_password_screen.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

void main() {
  for (final screen in [
    const LoginScreen(),
    const RegisterScreen(),
    const ForgotPasswordScreen(),
  ]) {
    for (final language in ['vi', 'en']) {
      testWidgets(
        '${screen.runtimeType} fits narrow width and large $language text',
        (tester) async {
          tester.view.physicalSize = const Size(320, 600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(language),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.5)),
                child: child!,
              ),
              home: screen,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -1500),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
