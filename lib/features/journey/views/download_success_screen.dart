import 'package:flutter/material.dart';
import 'widgets/trekking_button.dart';

/// Màn hình "Bản đồ đã sẵn sàng!" sau khi download thành công.
class DownloadSuccessScreen extends StatelessWidget {
  final String routeId;
  const DownloadSuccessScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // ── Success icon ────────────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Bản đồ đã sẵn sàng!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Mọi dữ liệu đã được lưu trữ an toàn ngoại tuyến.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 36),
              // ── Features list ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: const [
                    _FeatureRow(
                        label:
                            'Offline Map (Bản đồ ngoại tuyến)'),
                    _FeatureRow(
                        label:
                            'Hiking Trail (Đường mòn chi tiết)'),
                    _FeatureRow(
                        label:
                            'Waypoints (Các điểm dừng chân)'),
                    _FeatureRow(
                        label:
                            'Backtrack (Chế độ quay lại tự động)'),
                  ],
                ),
              ),

              const Spacer(),
              // ── CTAs ─────────────────────────────────────────────────────
              TrekkingPrimaryButton(
                label: 'Bắt đầu hành trình',
                icon: Icons.play_arrow,
                onPressed: () {
                  // Pop back to journey detail
                  Navigator.of(context)
                    ..pop() // download success
                    ..pop(); // route detail
                },
              ),
              const SizedBox(height: 12),
              TrekkingSecondaryButton(
                label: 'Xem bản đồ',
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              size: 16, color: Color(0xFF4CAF50)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}
