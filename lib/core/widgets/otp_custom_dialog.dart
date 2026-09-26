import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

typedef OtpCustom = OtpDialog;
typedef OtpCustomDialog = OtpDialog;

/// Widget Otp Input Custom gồm 6 ô số
class OtpCustomInput extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpCustomInput({
    super.key,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpCustomInput> createState() => _OtpCustomInputState();
}

class _OtpCustomInputState extends State<OtpCustomInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Expanded(
          child: Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              maxLength: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                final otp = _currentOtp;
                widget.onChanged?.call(otp);

                if (value.isNotEmpty) {
                  if (index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else {
                    _focusNodes[index].unfocus();
                  }
                } else if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}

/// Dialog xác thực sử dụng OtpCustomInput
class OtpDialog extends StatefulWidget {
  final String? email;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onResend;

  const OtpDialog({
    super.key,
    this.email,
    this.onSubmitted,
    this.onResend,
  });

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  String _enteredOtp = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      title: Text(
        l10n.otpDialogTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.email != null && widget.email!.isNotEmpty) ...[
              Text(
                l10n.otpSentTo,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            OtpCustomInput(
              onChanged: (otp) {
                _enteredOtp = otp;
              },
              onCompleted: (otp) {
                _enteredOtp = otp;
                widget.onSubmitted?.call(otp);
              },
            ),
            if (widget.onResend != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onResend,
                child: Text(
                  l10n.resendOtp,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancelButton,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: () {
            if (_enteredOtp.length == 6) {
              widget.onSubmitted?.call(_enteredOtp);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(l10n.confirmButton),
        ),
      ],
    );
  }
}