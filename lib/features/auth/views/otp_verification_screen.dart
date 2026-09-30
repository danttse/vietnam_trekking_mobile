import 'package:flutter/material.dart';

import '../../../core/widgets/otp_custom_dialog.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/register_viewmodel.dart';
import '../../user_navigation/views/user_navigation_screen.dart';

/// Màn hình xác thực OTP sau đăng ký (Bước 2 của luồng đăng ký).
///
/// Nhận [email] và [viewModel] từ [RegisterScreen] để tái sử dụng
/// trạng thái đã có (OTP countdown, savedEmail, v.v.).
///
/// Validates: Requirements 5.2–5.7, 5.11
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final RegisterViewModel viewModel;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.viewModel,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _enteredOtp = '';

  RegisterViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onConfirm() async {
    if (_enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.otpIncompleteError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final success = await _viewModel.verifyEmail(
      email: widget.email,
      otp: _enteredOtp,
    );

    if (!mounted) return;

    if (success) {
      // Đăng ký + xác minh thành công → về màn hình chính
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserNavigationScreen()),
        (_) => false,
      );
    } else {
      // Lỗi hiển thị ngay dưới input — không cần SnackBar thêm
    }
  }

  Future<void> _onResend() async {
    await _viewModel.resendOtp(widget.email);
    if (!mounted) return;

    if (_viewModel.otpErrorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.otpResendSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── AppBar row ────────────────────────────────────────────────
              SizedBox(
                height: 56,
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
                          backgroundColor:
                              colorScheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Text(
                      l10n.otpVerificationTitle,
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

              const SizedBox(height: 40),

              // ── Icon ─────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerLow,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: colorScheme.primary,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Title & description ───────────────────────────────────────
              Text(
                l10n.otpVerificationTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.otpSentTo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // ── OTP input ─────────────────────────────────────────────────
              AbsorbPointer(
                absorbing: _viewModel.isOtpDisabled,
                child: Opacity(
                  opacity: _viewModel.isOtpDisabled ? 0.4 : 1.0,
                  child: OtpCustomInput(
                    onChanged: (otp) => _enteredOtp = otp,
                    onCompleted: (otp) {
                      _enteredOtp = otp;
                    },
                  ),
                ),
              ),

              // ── Error message ─────────────────────────────────────────────
              if (_viewModel.otpErrorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _viewModel.otpErrorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Countdown + Resend ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_viewModel.otpSecondsRemaining > 0) ...[
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.otpExpiresIn} ${_formatCountdown(_viewModel.otpSecondsRemaining)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    Text(
                      l10n.otpExpiredLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // ── Resend button ─────────────────────────────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: (_viewModel.isOtpLoading || _viewModel.otpSecondsRemaining > 0)
                      ? null
                      : _onResend,
                  icon: _viewModel.isOtpLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: _viewModel.otpSecondsRemaining > 0
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.primary,
                        ),
                  label: Text(
                    l10n.resendOtp,
                    style: TextStyle(
                      color: _viewModel.otpSecondsRemaining > 0
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Confirm button ────────────────────────────────────────────
              BtnLoginPrimary(
                text: l10n.confirmButton,
                isLoading: _viewModel.isOtpLoading,
                onPressed: _viewModel.isOtpDisabled ? () {} : _onConfirm,
              ),

              const SizedBox(height: 16),

              // ── Back to login ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () {
                      // Pop back past RegisterScreen all the way to LoginScreen
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
