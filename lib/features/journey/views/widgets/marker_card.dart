import 'package:flutter/material.dart';
import '../../data/models/marker_model.dart';

/// Card cho một Journey Marker trong danh sách / bottom sheet.
class MarkerCard extends StatelessWidget {
  final MarkerModel marker;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MarkerCard({
    super.key,
    required this.marker,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _typeColor(marker.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_typeIcon(marker.type), size: 18, color: color),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        marker.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    if (!marker.isSynced)
                      const Icon(Icons.cloud_off,
                          size: 12, color: Colors.grey),
                  ],
                ),
                Text(
                  marker.typeLabel,
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                ),
                if (marker.note != null && marker.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      marker.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          // Actions
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  size: 18, color: cs.onSurfaceVariant),
              color: cs.surfaceContainerHighest,
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ]),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Xóa',
                          style: TextStyle(color: Colors.redAccent)),
                    ]),
                  ),
              ],
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
            ),
        ],
      ),
    );
  }

  static Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'DANGER':
        return Colors.redAccent;
      case 'SUMMIT':
        return const Color(0xFF9C27B0);
      case 'WATER_POINT':
        return const Color(0xFF2196F3);
      case 'CAMP':
        return const Color(0xFFFF9800);
      case 'VIEWPOINT':
      case 'PHOTO_SPOT':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  static IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'VIEWPOINT':
        return Icons.visibility_outlined;
      case 'REST_POINT':
        return Icons.chair_outlined;
      case 'WATER_POINT':
        return Icons.water_drop_outlined;
      case 'CAMP':
        return Icons.night_shelter_outlined;
      case 'DANGER':
        return Icons.warning_amber_outlined;
      case 'INTERSECTION':
        return Icons.call_split_outlined;
      case 'SUMMIT':
        return Icons.landscape_outlined;
      case 'LANDMARK':
        return Icons.place_outlined;
      case 'PHOTO_SPOT':
        return Icons.camera_alt_outlined;
      default:
        return Icons.push_pin_outlined;
    }
  }
}
