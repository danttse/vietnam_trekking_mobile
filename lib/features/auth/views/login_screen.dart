import 'package:flutter/material.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../view_models/login_viewmodel.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  Widget build(BuildContext context) {
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
              'TrekViệt',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color:Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Hành trình mây ngàn Việt Nam',
              style: TextStyle(
                fontSize: 14,
                color:Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            EditTextAuthCustom(
              label: 'Email',
              hintText: 'Nhập email',
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            EditTextAuthCustom(
              label: 'Mật khẩu',
              hintText: 'Nhập mật khẩu',
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _viewModel.toggleForgotPassword();
                },
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _viewModel.isLoading
                    ? null
                    : () {
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        _viewModel.login(email, password);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _viewModel.isLoading
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Đăng nhập',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Divider(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  thickness: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hoặc',
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
            ],),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  print('Đăng nhập bằng Google');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 28),
                label: Text('Đăng nhập với Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onSurface),),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bạn chưa có tài khoản?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('Chuyển đến màn hình đăng ký');
                  },
                  child: Text(
                    ' Đăng ký ngay',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            )
          ],
        ),
        ),
      ),
    );
  }
}