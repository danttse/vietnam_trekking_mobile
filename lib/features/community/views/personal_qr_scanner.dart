import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';

class PersonalQrScanner extends StatefulWidget {
  const PersonalQrScanner({super.key});
  @override
  State<PersonalQrScanner> createState() => _ScannerState();
}

class _ScannerState extends State<PersonalQrScanner> {
  final controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool done = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          AppTopBarWithBack(
            title: 'Quét QR cá nhân',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final value = capture.barcodes
                    .map((b) => b.rawValue)
                    .whereType<String>()
                    .firstOrNull;
                if (done || value == null) return;
                if (!RegExp(r'^trekviet://community/user/[a-f0-9]{48}$')
                    .hasMatch(value)) {
                  return;
                }
                done = true;
                Navigator.pop(context, value);
              },
              errorBuilder: (context, error) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Không mở được camera. Hãy cấp quyền camera trong cài đặt hoặc quay lại nhập nội dung QR.',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
