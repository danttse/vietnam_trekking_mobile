import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/views/forgot_password_screen.dart';
import '../view_models/change_password_viewmodel.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ChangePasswordViewModel _viewModel = ChangePasswordViewModel();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final success = await _viewModel.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.changePasswordSuccess),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(title: l10n.changePasswordTitle),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        EditTextAuthCustom(
                          label: l10n.currentPasswordLabel,
                          hintText: l10n.currentPasswordHint,
                          obscureText: _viewModel.isCurrentPasswordObscured,
                          controller: _currentPasswordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _viewModel.isCurrentPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            onPressed:
                                _viewModel.toggleCurrentPasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 16),
                        EditTextAuthCustom(
                          label: l10n.newPasswordLabelUpper,
                          hintText: l10n.newPasswordHint,
                          obscureText: _viewModel.isNewPasswordObscured,
                          controller: _newPasswordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _viewModel.isNewPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            onPressed:
                                _viewModel.toggleNewPasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 16),
                        EditTextAuthCustom(
                          label: l10n.confirmNewPasswordLabelUpper,
                          hintText: l10n.confirmNewPasswordHint,
                          obscureText: _viewModel.isConfirmPasswordObscured,
                          controller: _confirmPasswordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _viewModel.isConfirmPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            onPressed:
                                _viewModel.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 4,
                              ),
                              child: Text(
                                l10n.forgotPassword,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_viewModel.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _viewModel.errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        BtnLoginPrimary(
                          text: l10n.updatePasswordButton,
                          isLoading: _viewModel.isLoading,
                          onPressed: _viewModel.isLoading ? null : _onSubmit,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
