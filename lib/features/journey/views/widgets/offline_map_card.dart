import 'package:flutter/material.dart';
import '../../viewmodels/route_detail_viewmodel.dart';
import '../../data/models/route_model.dart';

/// Card "Bản đồ lộ trình" nhỏ trong Journey Detail.
/// Hiển thị preview + nút "Xem bản đồ".
class RouteMapPreview extends StatelessWidget {
  final VoidCallback? onViewMap;
  final String? mapImageUrl;

  const RouteMapPreview({
    super.key,
    this.onViewMap,
    this.mapImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onViewMap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1A0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (mapImageUrl != null)
                Positioned.fill(
                  child: Image.network(
                    mapImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _MapPlaceholder(),
                  ),
                )
              else
                _MapPlaceholder(),
              // Overlay label
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('APEX TRAIL',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
              // Tap hint
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Xem bản đồ',
                      style:
                          TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1A0F),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: Color(0xFF4A7A4A), size: 36),
            SizedBox(height: 6),
            Text('Bản đồ lộ trình',
                style:
                    TextStyle(color: Color(0xFF4A7A4A), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Card "Tải bản đồ Offline" trong Route Detail.
class OfflineMapCard extends StatelessWidget {
  final OfflinePackageInfo? packageInfo;
  final OfflineMapStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const OfflineMapCard({
    super.key,
    required this.packageInfo,
    required this.status,
    required this.downloadProgress,
    required this.onDownload,
    required this.onCancel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (packageInfo != null) ...[
            Row(
              children: [
                Icon(Icons.download_outlined,
                    size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  packageInfo!.mapName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                if (status == OfflineMapStatus.ready)
                  const Icon(Icons.check_circle,
                      color: Color(0xFF4CAF50), size: 18),
                if (status == OfflineMapStatus.outdated)
                  const Icon(Icons.update,
                      color: Color(0xFFFFB74D), size: 18),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(label: 'Bản đồ', value: packageInfo!.mapName),
            _InfoRow(label: 'Mức Zoom', value: packageInfo!.zoomLabel),
            _InfoRow(label: 'Dung lượng', value: packageInfo!.sizeMb),
            _InfoRow(
                label: 'Điểm kiểm soát',
                value: '${packageInfo!.waypointCount} Waypoints'),
            _InfoRow(
                label: 'Đường mòn',
                value:
                    packageInfo!.supportsTrail ? 'Có hỗ trợ' : 'Không'),
          ],
          const SizedBox(height: 12),
          if (status == OfflineMapStatus.downloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: downloadProgress,
                minHeight: 8,
                backgroundColor: cs.surface,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(downloadProgress * 100).toStringAsFixed(0)}% đang tải...',
              style:
                  TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
                child: const Text('Hủy tải xuống'),
              ),
            ),
          ] else if (status == OfflineMapStatus.failed) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
              ),
            ),
          ] else if (status == OfflineMapStatus.ready) ...[
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF4CAF50), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Bản đồ đã sẵn sàng offline',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: Text(
                    status == OfflineMapStatus.outdated
                        ? 'Cập nhật bản đồ'
                        : 'Tải bản đồ Offline'),
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: cs.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface)),
        ],
      ),
    );
  }
}
