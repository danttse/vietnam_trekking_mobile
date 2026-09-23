import 'package:flutter/material.dart';
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
                const SnackBar(
                  content: Text('Xác thực OTP thành công! Vui lòng nhập mật khẩu mới.'),
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
        const SnackBar(
          content: Text('Cập nhật mật khẩu thành công! Vui lòng đăng nhập lại.'),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Text(
                      viewModel.isOtpVerified ? 'Đặt lại mật khẩu' : 'Khôi phục mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerLow,
                ),
                child: Icon(
                  viewModel.isOtpVerified ? Icons.lock_reset_rounded : Icons.lock_outline_rounded,
                  color: colorScheme.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),

              // Chuyển đổi giữa 2 bước
              viewModel.isOtpVerified ? _buildChangePassword() : _buildEnterEmailAddress(),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quay lại ',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Đăng nhập',
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

  // Bước 1: Nhập email
  Widget _buildEnterEmailAddress() {
    return Column(
      children: [
        Text(
          'Nhập email đã đăng ký của bạn bên dưới. Chúng tôi\nsẽ gửi một liên kết an toàn để bạn đặt lại\nmật khẩu mới.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 16),
        EditTextAuthCustom(
          label: 'Email',
          hintText: 'Nhập email',
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        BtnLoginPrimary(
          text: 'Gửi liên kết đặt lại',
          isLoading: viewModel.isLoading,
          onPressed: _onSendEmail,
        ),
      ],
    );
  }

  // Bước 2: Đổi mật khẩu mới
  Widget _buildChangePassword() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'Vui lòng nhập mật khẩu mới cho tài khoản của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        EditTextAuthCustom(
          label: 'Mật khẩu mới',
          hintText: 'Nhập mật khẩu mới',
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
          label: 'Xác nhận mật khẩu',
          hintText: 'Nhập lại mật khẩu',
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
          text: 'Cập nhật mật khẩu',
          isLoading: viewModel.isLoading,
          onPressed: _onUpdatePassword,
        ),
      ],
    );
  }
}