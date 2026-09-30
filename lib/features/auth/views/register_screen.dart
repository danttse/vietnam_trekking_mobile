import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../repository/auth_repository_impl.dart';
import '../view_models/register_viewmodel.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late final SecureTokenStorage _tokenStorage;
  late final AuthEventBus _eventBus;
  late final Dio _dio;
  late final AuthRepositoryImpl _repository;
  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tokenStorage = const SecureTokenStorage();
    _eventBus = AuthEventBus(); // singleton
    _dio = DioClient.createDio(tokenStorage: _tokenStorage, eventBus: _eventBus);
    _repository = AuthRepositoryImpl(dio: _dio, tokenStorage: _tokenStorage);
    _viewModel = RegisterViewModel(repository: _repository, tokenStorage: _tokenStorage);

    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

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
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.appTagline,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              EditTextAuthCustom(
                label: l10n.fullNameLabel,
                hintText: l10n.fullNameHint,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
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
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _viewModel.togglePasswordVisibility();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              EditTextAuthCustom(
                label: l10n.confirmPasswordLabel,
                hintText: l10n.confirmPasswordHint,
                obscureText: _viewModel.isConfirmPasswordObscured,
                controller: _confirmPasswordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _viewModel.isConfirmPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _viewModel.toggleConfirmPasswordVisibility();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _viewModel.isAgreeToTerms,
                    checkColor: Theme.of(context).colorScheme.surfaceContainer,
                    side: BorderSide(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _viewModel.toggleAgreeToTerms(value);
                      });
                    },
                  ),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.agreeToTermsPrefix,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Show Terms of Service
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.termsOfService,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          l10n.and,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Show Privacy Policy
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.privacyPolicy,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Req 5.9, 5.10, 5.11: Hiển thị thông báo lỗi từ ViewModel
              if (_viewModel.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _viewModel.errorMessage!,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              BtnLoginPrimary(
                text: l10n.registerButton,
                isLoading: _viewModel.isLoading,
                onPressed: () async {
                  final name = _nameController.text;
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  final confirmPassword = _confirmPasswordController.text;

                  setState(() {});

                  // Req 5.1: Gọi register với named params
                  // Req 5.2: Chỉ xử lý khi register() trả về true (OTP step starts)
                  final success = await _viewModel.register(
                    displayName: name,
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword,
                    agreedToTerms: _viewModel.isAgreeToTerms,
                  );

                  if (success && context.mounted) {
                    // Bước 2: navigate sang màn OTP xác thực email
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtpVerificationScreen(
                          email: email.trim(),
                          viewModel: _viewModel,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              BtnOutlineStyle(
                text: l10n.registerWithGoogle,
                icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 28),
                onPressed: () {
                  // TODO: Google Sign-Up
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.loginButton,
                      style: TextStyle(
                        color: colorScheme.primary,
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
