import 'package:flutter/material.dart';
import '../view_models/forgot_password_viewmodel.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/otp_custom_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget{
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState()=>_ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              SizedBox(
                height:48,
                child: Stack(
                alignment: Alignment.center,
                children: [
                Positioned(
                  left: 0,
                  child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  ), ),
                ),
                Text(
                  'Khôi phục mật khẩu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              ],),
              ),
              const SizedBox(height:50),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập email đã đăng ký của bạn bên dưới. Chúng tôi\n'
                'sẽ gửi một liên kết an toàn để bạn đặt lại\n' 
                'mật khẩu mới.',
                textAlign: TextAlign.center,
                style: TextStyle (
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
                onPressed: () async {
                  final email = _emailController.text;
                  final success = await viewModel.sendResetPasswordEmail(email);
                  if (!context.mounted) return;
                  if (success) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => OtpDialog(
                        email: email,
                        onResend: () {
                          viewModel.sendResetPasswordEmail(email);
                        },
                        onSubmitted: (otp) async {
                          final isVerified = await viewModel.verifyOtp(otp);
                          if (!context.mounted) return;
                          if (isVerified) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Xác thực OTP thành công!'),
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
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quay lại ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Đăng nhập',
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
      )
    );
  }
}