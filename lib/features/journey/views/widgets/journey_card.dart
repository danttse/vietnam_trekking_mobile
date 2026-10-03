import 'package:flutter/material.dart';
import '../../data/models/journey_model.dart';
import 'journey_status_badge.dart';

/// Card cho một Journey trong danh sách.
/// Bám sát thiết kế: dark card, ảnh thumbnail bên trái,
/// tên / địa điểm / ngày / stats bên phải.
class JourneyCard extends StatelessWidget {
  final JourneyModel journey;
  final VoidCallback? onTap;

  const JourneyCard({
    super.key,
    required this.journey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: _Thumbnail(imageUrl: journey.placeImageUrl),
            ),
            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      journey.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        height: 1.3,
                      ),
                    ),
                    if (journey.placeAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        journey.placeAddress!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Date range
                    if (_dateLabel.isNotEmpty)
                      Text(
                        _dateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Stats row
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.people_outline,
                          label: '${journey.memberCount ?? 0} thành viên',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          icon: Icons.route_outlined,
                          label: _distanceLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Status badge (right) ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: JourneyStatusBadge(status: journey.status, small: true),
            ),
          ],
        ),
      ),
    );
  }

  String get _dateLabel {
    final start = journey.plannedStartAt ?? journey.startedAt;
    final end = journey.completedAt;
    if (start == null) return '';
    final fmt = _fmtDate(start);
    if (end != null) return '$fmt - ${_fmtDate(end)}';
    return fmt;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _distanceLabel {
    final km = (journey.routeDistanceMeters ?? journey.distanceMeters) / 1000;
    return '${km.toStringAsFixed(0)} km';
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;
  const _Thumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const size = 88.0;
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xFF1E2D1E),
        child: const Icon(Icons.landscape_outlined,
            color: Color(0xFF4A7A4A), size: 32),
      );
    }
    return Image.network(
      imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        width: size,
        height: size,
        color: const Color(0xFF1E2D1E),
        child: const Icon(Icons.landscape_outlined,
            color: Color(0xFF4A7A4A), size: 32),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
