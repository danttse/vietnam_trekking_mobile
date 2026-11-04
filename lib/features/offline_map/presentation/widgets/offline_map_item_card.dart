import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';

class OfflineMapItemCard extends StatelessWidget {
  final DownloadedMap map;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final bool isInUse;

  const OfflineMapItemCard({
    super.key,
    required this.map,
    this.imageUrl,
    this.onTap,
    this.onDelete,
    this.isDeleting = false,
    this.isInUse = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInUse
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(colorScheme),
                        )
                      : _buildPlaceholder(colorScheme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        map.mapName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          // Tag loại bản đồ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              map.scope == 'ROUTE'
                                  ? 'Tuyến đường'
                                  : 'Địa điểm',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          // Badge hành trình đang đi
                          if (isInUse) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Đang đi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            map.sizeMBText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 13,
                            color: map.isReady
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              map.downloadedAt != null
                                  ? 'Đã tải: ${map.downloadedAt!.day}/${map.downloadedAt!.month}/${map.downloadedAt!.year}'
                                  : (map.isReady
                                      ? 'Sẵn sàng sử dụng offline'
                                      : map.status),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: isDeleting ? null : onDelete,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isInUse
                            ? colorScheme.onSurface.withValues(alpha: 0.05)
                            : colorScheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isInUse
                              ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                              : colorScheme.error.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isDeleting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.error,
                              ),
                            )
                          : Icon(
                              isInUse
                                  ? Icons.lock_outline_rounded
                                  : Icons.delete_outline_rounded,
                              size: 18,
                              color: isInUse
                                  ? colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6)
                                  : colorScheme.error,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            map.scope == 'ROUTE'
                ? Icons.alt_route_rounded
                : Icons.terrain_rounded,
            size: 26,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 2),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
