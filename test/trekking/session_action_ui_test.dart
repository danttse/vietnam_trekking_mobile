import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/core/services/token_storage.dart';
import 'package:vietnam_trekking_mobile/core/widgets/dialogs/session_expired_dialog.dart';
import 'package:vietnam_trekking_mobile/features/auth/repository/auth_repository.dart';
import 'package:vietnam_trekking_mobile/features/auth/services/google_signin_service.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/profile_setting_viewmodel.dart';

class LogoutRepository extends Fake implements AuthRepository {
  @override
  Future<void> logout({String? refreshToken}) async {}
}

class LogoutStorage extends Fake implements TokenStorage {
  @override
  Future<String?> getRefreshToken() async => 'refresh';
}

class LogoutGoogle extends Fake implements GoogleSignInService {
  @override
  Future<void> signOut() async {}
}

double contrast(Color a, Color b) {
  final first = a.computeLuminance(), second = b.computeLuminance();
  return (first > second ? first + .05 : second + .05) /
      (first > second ? second + .05 : first + .05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('manual logout emits loggedOut instead of an expired session', () async {
    final bus = AuthEventBus();
    final event = bus.stream.first;
    final vm = ProfileSettingViewModel(
      authRepository: LogoutRepository(),
      tokenStorage: LogoutStorage(),
      eventBus: bus,
      googleSignInService: LogoutGoogle(),
    );
    await vm.logout();
    expect(await event, AuthEvent.loggedOut);
    vm.dispose();
  });

  for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
    test('action colors have readable contrast in ${theme.brightness}', () {
      expect(
        contrast(theme.colorScheme.primary, theme.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
    });
    testWidgets(
      'expired session fits a small screen with large text in ${theme.brightness}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: const TextScaler.linear(2)),
                      child: SessionExpiredDialog(
                        onSignIn: () => pressed = true,
                      ),
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
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Đăng nhập lại'));
        expect(pressed, isTrue);
      },
    );
  }
}
