import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/features/auth/views/forgot_password_screen.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../repository/auth_repository_impl.dart';
import '../view_models/login_viewmodel.dart';
import '../../user_navigation/views/user_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final SecureTokenStorage _tokenStorage;
  late final AuthEventBus _eventBus;
  late final Dio _dio;
  late final AuthRepositoryImpl _repository;
  late final LoginViewModel _viewModel;

  StreamSubscription<AuthEvent>? _authExpiredSub;

  @override
  void initState() {
    super.initState();
    _tokenStorage = const SecureTokenStorage();
    _eventBus = AuthEventBus(); // singleton
    _dio = DioClient.createDio(tokenStorage: _tokenStorage, eventBus: _eventBus);
    _repository = AuthRepositoryImpl(dio: _dio, tokenStorage: _tokenStorage);
    _viewModel = LoginViewModel(repository: _repository, tokenStorage: _tokenStorage);

    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });

    // Req 2.7, 7.4: Lắng nghe sự kiện authExpired → điều hướng về LoginScreen
    _authExpiredSub = _eventBus.stream.listen((event) {
      if (event == AuthEvent.authExpired && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _authExpiredSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/img_app_logo_ver2.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.appTagline,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              EditTextAuthCustom(
                label: l10n.emailLabel,
                hintText: l10n.emailHint,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              EditTextAuthCustom(
                label: l10n.passwordLabel,
                hintText: l10n.passwordHint,
                obscureText: _viewModel.isPasswordObscured,
                controller: _passwordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _viewModel.isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _viewModel.togglePasswordVisibility();
                    });
                  },
                ),
              ),
              // Req 4.3–4.9: Hiển thị thông báo lỗi từ ViewModel
              if (_viewModel.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _viewModel.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                  },
                  child: Text(
                    l10n.forgotPassword,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BtnLoginPrimary(
                text: l10n.loginButton,
                isLoading: _viewModel.isLoading,
                onPressed: () async {
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  setState(() {});

                  // Req 4.2: Chỉ điều hướng khi login() trả về true
                  final success = await _viewModel.login(email, password);

                  if (success && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserNavigationScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.orDivider,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BtnOutlineStyle(
                text: l10n.loginWithGoogle,
                icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 28),
                onPressed: () {
                  // TODO: Google Sign-In
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.noAccount,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.registerNow,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
