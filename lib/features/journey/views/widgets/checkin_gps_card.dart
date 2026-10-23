import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../viewmodels/milestone_checkin_viewmodel.dart';

/// GPS diagram scaled to the actual distance and configured check-in radius.
class CheckinGpsCard extends StatelessWidget {
  final MilestoneCheckinViewModel viewModel;
  const CheckinGpsCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pos = viewModel.location.position;
    final radius = viewModel.allowedRadiusMeters.toDouble();
    final distance = (viewModel.distanceMeters ?? 0).toDouble();
    final extent = math
        .max(radius * 1.6, distance * 1.3)
        .clamp(1.0, double.infinity);
    final lat = viewModel.milestone.latitude;
    final dx = pos == null
        ? 0.0
        : (pos.longitude - viewModel.milestone.longitude) *
              111320 *
              math.cos(lat * math.pi / 180);
    final dy = pos == null ? 0.0 : (pos.latitude - lat) * 111320;
    return Container(
      height: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .4)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GpsPainter(
                radiusFraction: radius / extent,
                userOffset: pos == null
                    ? null
                    : Offset(dx / extent, -dy / extent),
                color: cs.primary,
                inRange: viewModel.isWithinRange,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _Caption(
              text: pos == null
                  ? 'GPS • chưa có vị trí'
                  : 'GPS • sai số ±${pos.accuracy.round()} m',
              icon: Icons.gps_fixed,
            ),
          ),
          const Positioned(
            top: 14,
            right: 14,
            child: _Caption(text: 'Bắc', icon: Icons.navigation),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 44),
              child: _Caption(text: viewModel.destinationName),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _Caption(
                      text: 'Vùng check-in ${viewModel.allowedRadiusMeters} m',
                      icon: Icons.radio_button_checked,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (pos != null)
                  const _Caption(text: 'Bạn', icon: Icons.person_pin_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _Caption({required this.text, this.icon});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 225),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: cs.primary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsPainter extends CustomPainter {
  final double radiusFraction;
  final Offset? userOffset;
  final Color color;
  final bool inRange;
  _GpsPainter({
    required this.radiusFraction,
    required this.userOffset,
    required this.color,
    required this.inRange,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final scale = math.min(size.width, size.height) * .36;
    final grid = Paint()
      ..color = color.withValues(alpha: .1)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final r = scale * radiusFraction;
    canvas.drawCircle(center, r, Paint()..color = color.withValues(alpha: .1));
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 60; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        i * math.pi / 30,
        math.pi / 60,
        false,
        stroke,
      );
    }
    if (userOffset != null) {
      final user = center + userOffset! * scale;
      canvas.drawLine(
        center,
        user,
        Paint()
          ..color = color.withValues(alpha: .5)
          ..strokeWidth = 2,
      );
      final blue = inRange ? const Color(0xFF3B82F6) : const Color(0xFFE8620A);
      canvas.drawCircle(user, 14, Paint()..color = blue.withValues(alpha: .2));
      canvas.drawCircle(user, 7, Paint()..color = Colors.white);
      canvas.drawCircle(user, 5, Paint()..color = blue);
    }
    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFFE8620A));
  }

  @override
  bool shouldRepaint(covariant _GpsPainter old) =>
      radiusFraction != old.radiusFraction ||
      userOffset != old.userOffset ||
      color != old.color ||
      inRange != old.inRange;
}
