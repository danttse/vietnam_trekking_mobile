import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/forgot_password_viewmodel.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/otp_custom_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ForgotPasswordViewModel viewModel = ForgotPasswordViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSendEmail() async {
    final email = _emailController.text;
    final success = await viewModel.sendResetPasswordEmail(email);
    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => OtpDialog(
          email: email,
          onResend: () => viewModel.sendResetPasswordEmail(email),
          onSubmitted: (otp) async {
            final isVerified = await viewModel.verifyOtp(otp);
            if (!dialogContext.mounted||!mounted) return;
            if (isVerified) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.otpVerifiedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (viewModel.otpErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.otpErrorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      );
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _onUpdatePassword() async {
    final success = await viewModel.updateNewPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.updatePasswordSuccess),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(
              title: viewModel.isOtpVerified
                  ? l10n.resetPasswordTitle
                  : l10n.forgotPasswordTitle,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerLow,
                      ),
                      child: Icon(
                        viewModel.isOtpVerified
                            ? Icons.lock_reset_rounded
                            : Icons.lock_outline_rounded,
                        color: colorScheme.primary,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chuyển đổi giữa 2 bước
                    viewModel.isOtpVerified
                        ? _buildChangePassword()
                        : _buildEnterEmailAddress(),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.backToLogin,
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }
  Widget _buildEnterEmailAddress() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.forgotPasswordDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 16),
        EditTextAuthCustom(
          label: l10n.emailLabel,
          hintText: l10n.emailHint,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        BtnLoginPrimary(
          text: l10n.sendResetLink,
          isLoading: viewModel.isLoading,
          onPressed: _onSendEmail,
        ),
      ],
    );
  }
  Widget _buildChangePassword() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          l10n.resetPasswordDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        EditTextAuthCustom(
          label: l10n.newPasswordLabel,
          hintText: l10n.newPasswordHint,
          obscureText: viewModel.isPasswordObscured,
          controller: _passwordController,
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.isPasswordObscured ? Icons.visibility_off : Icons.visibility,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => viewModel.togglePasswordVisibility(),
          ),
        ),
        const SizedBox(height: 16),
        EditTextAuthCustom(
          label: l10n.confirmPasswordLabel,
          hintText: l10n.confirmPasswordHint,
          obscureText: viewModel.isConfirmPasswordObscured,
          controller: _confirmPasswordController,
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => viewModel.toggleConfirmPasswordVisibility(),
          ),
        ),
        const SizedBox(height: 16),
        BtnLoginPrimary(
          text: l10n.updatePasswordButton,
          isLoading: viewModel.isLoading,
          onPressed: _onUpdatePassword,
        ),
      ],
    );
  }
}