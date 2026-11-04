import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../../core/widgets/feedback/app_snack_bar.dart';
import '../../../../core/database/database.dart';
import '../viewmodels/offline_map_management_viewmodel.dart';
import '../widgets/offline_map_item_card.dart';

class OfflineMapManagementScreen extends StatefulWidget {
  final OfflineMapManagementViewModel? viewModel;

  const OfflineMapManagementScreen({super.key, this.viewModel});

  @override
  State<OfflineMapManagementScreen> createState() =>
      _OfflineMapManagementScreenState();
}

class _OfflineMapManagementScreenState
    extends State<OfflineMapManagementScreen> {
  late final OfflineMapManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? OfflineMapManagementViewModel();
    _viewModel.loadMaps();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// Xử lý khi nhấn nút xóa
  void _handleDeleteClick(DownloadedMap map, bool isInUse) {
    if (isInUse) {
      // Nếu bản đồ đang phục vụ hành trình đang đi -> Chặn và báo lỗi bằng SnackBar
      AppSnackBar.showError(
        context,
        'Bản đồ "${map.mapName}" đang được sử dụng trong hành trình đang diễn ra.',
      );
      return;
    }
    _confirmDelete(map);
  }

  Future<void> _confirmDelete(DownloadedMap map) async {
    final colorScheme = Theme.of(context).colorScheme;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xóa bản đồ offline',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bản đồ "${map.mapName}"?\nDữ liệu ngoại tuyến sẽ được giải phóng khỏi thiết bị.',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Hủy',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa bản đồ'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final success = await _viewModel.deleteMap(map.mapId);
      if (mounted) {
        if (success) {
          AppSnackBar.showSuccess(
            context,
            'Đã xóa bản đồ "${map.mapName}" thành công',
          );
        } else {
          AppSnackBar.showError(
            context,
            _viewModel.error ?? 'Không thể xóa bản đồ',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBarWithBack(title: 'Bản đồ offline'),

            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading && _viewModel.maps.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_viewModel.error != null && _viewModel.maps.isEmpty) {
                    return _buildErrorState(colorScheme);
                  }

                  return RefreshIndicator(
                    onRefresh: _viewModel.loadMaps,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: _buildStorageSummaryBanner(colorScheme),
                        ),
                        Expanded(
                          child: _viewModel.maps.isEmpty
                              ? _buildEmptyState(colorScheme)
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _viewModel.maps.length,
                                  itemBuilder: (context, index) {
                                    final map = _viewModel.maps[index];
                                    final imageUrl =
                                        _viewModel.getPlaceImage(map.mapId);
                                    final isDeleting =
                                        _viewModel.deletingMapId == map.mapId;
                                    final isInUse =
                                        _viewModel.isMapInUse(map);

                                    return OfflineMapItemCard(
                                      map: map,
                                      imageUrl: imageUrl,
                                      isDeleting: isDeleting,
                                      isInUse: isInUse,
                                      onDelete: () =>
                                          _handleDeleteClick(map, isInUse),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSummaryBanner(ColorScheme colorScheme) {
    final info = _viewModel.storageInfo;
    final totalMB = info?.totalMB ?? '0.0';
    final count = _viewModel.mapCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.storage_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dung lượng đã sử dụng',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$totalMB MB',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count bản đồ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 38,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Chưa có bản đồ offline',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có thể tải bản đồ trước khi bắt đầu hành trình để xem bản đồ ngay cả khi không có kết nối mạng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              _viewModel.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _viewModel.loadMaps,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
