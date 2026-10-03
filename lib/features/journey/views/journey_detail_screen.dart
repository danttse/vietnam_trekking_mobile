import 'package:flutter/material.dart';
import '../viewmodels/journey_detail_viewmodel.dart';
import '../data/models/journey_model.dart';
import 'widgets/journey_status_badge.dart';
import 'widgets/journey_stats_row.dart';
import 'widgets/journey_progress_bar.dart';
import 'widgets/milestone_timeline.dart';
import 'widgets/offline_map_card.dart';
import 'widgets/trekking_button.dart';
import 'widgets/trekking_empty_state.dart';
import 'checkin_screen.dart';
import 'journey_map_screen.dart';
import 'review_screen.dart';
import 'contribution_screen.dart';
import '../data/models/milestone_model.dart';

class JourneyDetailScreen extends StatefulWidget {
  final String journeyId;
  /// userId từ auth state — không hard-code, truyền từ caller
  final String userId;

  const JourneyDetailScreen({
    super.key,
    required this.journeyId,
    required this.userId,
  });

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  late final JourneyDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = JourneyDetailViewModel(journeyId: widget.journeyId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.load());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  // ── Status actions ────────────────────────────────────────────────────────

  Future<void> _handleStart() async {
    final ok = await _vm.startJourney();
    if (!ok && mounted) {
      _showError(_vm.error ?? 'Không thể bắt đầu hành trình');
    }
  }

  Future<void> _handlePause() async {
    final ok = await _vm.pauseJourney();
    if (!ok && mounted) _showError(_vm.error ?? 'Lỗi');
  }

  Future<void> _handleResume() async {
    final ok = await _vm.resumeJourney();
    if (!ok && mounted) _showError(_vm.error ?? 'Lỗi');
  }

  Future<void> _handleComplete() async {
    final confirm = await _showConfirmDialog(
      title: 'Hoàn thành hành trình?',
      message: 'Bạn có chắc muốn kết thúc hành trình này không?',
      confirmLabel: 'Hoàn thành',
    );
    if (confirm != true) return;
    final ok = await _vm.completeJourney();
    if (!ok && mounted) {
      _showError(_vm.error ?? 'Lỗi');
      return;
    }
    if (mounted) _offerContribution();
  }

  /// Sau khi complete journey → hỏi user có muốn đóng góp cung đường không.
  Future<void> _offerContribution() async {
    if (_vm.journey == null) return;
    final cs = Theme.of(context).colorScheme;

    final want = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHighest,
        title: Text(
          'Hành trình hoàn thành! 🎉',
          style: TextStyle(color: cs.onSurface, fontSize: 16),
        ),
        content: Text(
          'Bạn có muốn đóng góp dữ liệu GPS của hành trình này cho cộng đồng trekker không?',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8620A),
            ),
            child: const Text('Đóng góp ngay'),
          ),
        ],
      ),
    );

    if (want == true && mounted && _vm.journey != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ContributionScreen(
          journey: _vm.journey!,
          markers: _vm.markers,
          userId: widget.userId,
        ),
      ));
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await _showConfirmDialog(
      title: 'Hủy hành trình?',
      message: 'Hành trình sẽ bị hủy và không thể khôi phục.',
      confirmLabel: 'Hủy hành trình',
      isDanger: true,
    );
    if (confirm != true) return;
    final ok = await _vm.cancelJourney();
    if (ok && mounted) Navigator.of(context).pop();
  }

  void _openCheckin(MilestoneModel milestone) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CheckinScreen(
        milestone: milestone,
        journeyId: widget.journeyId,
        userId: widget.userId,
      ),
    ));
  }

  void _openMap() {
    if (_vm.journey == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JourneyMapScreen(
        journey: _vm.journey!,
        milestones: _vm.milestones,
        markers: _vm.markers,
        routeId: _vm.journey!.trekkingRouteId,
      ),
    ));
  }

  void _openReview() {
    if (_vm.journey == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReviewScreen(
        placeId: _vm.journey!.trekkingPlaceId,
        placeName: _vm.journey?.placeName,
        journeyId: widget.journeyId,
      ),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHighest,
        title: Text(title,
            style: TextStyle(color: cs.onSurface, fontSize: 16)),
        content: Text(message,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  isDanger ? Colors.redAccent : const Color(0xFFE8620A),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.state == JourneyDetailState.loading) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFE8620A))),
          );
        }
        if (_vm.state == JourneyDetailState.error) {
          return Scaffold(
            appBar: AppBar(),
            body: TrekkingEmptyState.error(
              message: _vm.error,
              onRetry: _vm.load,
            ),
          );
        }
        if (_vm.journey == null) {
          return Scaffold(
            appBar: AppBar(),
            body:
                const TrekkingEmptyState(
                    icon: Icons.search_off, title: 'Không tìm thấy hành trình'),
          );
        }
        return _buildContent(_vm.journey!);
      },
    );
  }

  Widget _buildContent(JourneyModel j) {
    final cs = Theme.of(context).colorScheme;
    final status = j.status;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(j, cs),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats ────────────────────────────────────────────────
                  _buildStats(j, status, cs),
                  const SizedBox(height: 16),
                  // ── Progress ─────────────────────────────────────────────
                  if (status != 'PLANNED') ...[
                    JourneyProgressBar(
                      checkedIn: j.checkinCount,
                      total: _vm.milestones.length,
                    ),
                    const SizedBox(height: 20),
                  ],
                  // ── Milestone timeline ────────────────────────────────────
                  Text('LỘ TRÌNH ĐIỂM KIỂM SOÁT',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  MilestoneTimeline(
                    milestones: _vm.milestones,
                    onCheckinTap: status == 'ACTIVE'
                        ? _openCheckin
                        : null,
                  ),
                  const SizedBox(height: 20),
                  // ── Map preview ───────────────────────────────────────────
                  Text('BẢN ĐỒ LỘ TRÌNH',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  RouteMapPreview(onViewMap: _openMap),
                  // ── Photo gallery (ACTIVE) ─────────────────────────────
                  if (status == 'ACTIVE') ...[
                    const SizedBox(height: 20),
                    _buildPhotoStrip(cs),
                  ],
                  // ── COMPLETED extra actions ───────────────────────────────
                  if (status == 'COMPLETED') ...[
                    const SizedBox(height: 20),
                    Text('ẢNH KỶ NIỆM CHUYẾN ĐI',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    _buildMemoryPhotos(cs),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(j, status, cs),
    );
  }

  // ── Sliver AppBar with hero image ─────────────────────────────────────────

  Widget _buildSliverAppBar(JourneyModel j, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Colors.white),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: JourneyStatusBadge(status: j.status),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            j.placeImageUrl != null
                ? Image.network(j.placeImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Container(color: const Color(0xFF0D1A0F)))
                : Container(color: const Color(0xFF0D1A0F),
                    child: const Icon(Icons.landscape,
                        size: 64, color: Color(0xFF1E3A1E))),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Title overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    j.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (j.placeAddress != null)
                    Text(
                      j.placeAddress!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStats(JourneyModel j, String status, ColorScheme cs) {
    final distKm = j.distanceMeters / 1000;
    final totalDistKm = (j.routeDistanceMeters ?? j.distanceMeters) / 1000;
    final days = j.durationSeconds > 0
        ? (j.durationSeconds / 86400).ceil()
        : null;

    if (status == 'ACTIVE' || status == 'PAUSED') {
      return JourneyStatsRow(stats: [
        JourneyStat(
          value:
              '${distKm.toStringAsFixed(1)} / ${totalDistKm.toStringAsFixed(0)} km',
          label: 'Quãng đường',
        ),
        JourneyStat(
          value: '${days ?? 2} / 3 ngày',
          label: 'Thời gian còn lại',
        ),
        JourneyStat(
          value: '${j.maxAltitude?.toInt() ?? 1100} m',
          label: 'Độ cao hiện tại',
        ),
      ]);
    } else if (status == 'COMPLETED') {
      return JourneyStatsRow(stats: [
        JourneyStat(
          value: '${totalDistKm.toStringAsFixed(0)} km',
          label: 'Quãng đường',
        ),
        JourneyStat(
          value: '${days ?? 4} ngày',
          label: 'Thời gian đi',
        ),
        JourneyStat(
          value: '${j.checkinCount} tỉnh',
          label: 'Tỉnh đi qua',
        ),
        JourneyStat(
          value: '${j.maxAltitude?.toInt() ?? 1500} m',
          label: 'Độ cao tối đa',
        ),
      ]);
    }

    // PLANNED
    return JourneyStatsRow(stats: [
      JourneyStat(
        value: '${totalDistKm.toStringAsFixed(1)} / ${totalDistKm.toStringAsFixed(0)} km',
        label: 'Quãng đường',
      ),
      JourneyStat(
        value: '2 / 3 ngày',
        label: 'Thời gian còn lại',
      ),
      JourneyStat(
        value: '${_vm.milestones.where((m) => m.isCheckedIn).length} / ${_vm.milestones.length}',
        label: 'Điểm check-in',
      ),
    ]);
  }

  // ── Photo strip (ACTIVE) ──────────────────────────────────────────────────

  Widget _buildPhotoStrip(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('THÊM HÌNH ẢNH',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {/* pick photo */},
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: cs.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 22, color: cs.onSurfaceVariant),
                      const SizedBox(height: 4),
                      Text('Thêm ảnh',
                          style: TextStyle(
                              fontSize: 9, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Memory photos (COMPLETED) ─────────────────────────────────────────────

  Widget _buildMemoryPhotos(ColorScheme cs) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 120,
            color: cs.surfaceContainerHighest,
            child: Icon(Icons.landscape,
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                size: 40),
          ),
        ),
      ),
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────

  Widget _buildBottomActions(
      JourneyModel j, String status, ColorScheme cs) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'PLANNED') ...[
              TrekkingPrimaryButton(
                label: 'Bắt đầu hành trình',
                loading: _vm.actionLoading,
                onPressed: _handleStart,
              ),
              const SizedBox(height: 8),
              TrekkingSecondaryButton(
                label: 'Xem bản đồ',
                onPressed: _openMap,
              ),
            ] else if (status == 'ACTIVE') ...[
              TrekkingPrimaryButton(
                label: 'Tạm dừng',
                loading: _vm.actionLoading,
                onPressed: _handlePause,
              ),
              const SizedBox(height: 8),
              TrekkingSecondaryButton(
                label: 'Xem bản đồ',
                onPressed: _openMap,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _handleComplete,
                child: const Text('Hoàn thành hành trình',
                    style: TextStyle(color: Color(0xFF4CAF50), fontSize: 13)),
              ),
            ] else if (status == 'PAUSED') ...[
              TrekkingPrimaryButton(
                label: 'Tiếp tục hành trình',
                loading: _vm.actionLoading,
                onPressed: _handleResume,
              ),
              const SizedBox(height: 8),
              TrekkingSecondaryButton(
                label: 'Xem bản đồ',
                onPressed: _openMap,
              ),
            ] else if (status == 'COMPLETED') ...[
              TrekkingPrimaryButton(
                label: 'Chia sẻ thành tích',
                icon: Icons.share_outlined,
                onPressed: () {/* share */},
              ),
              const SizedBox(height: 8),
              TrekkingSecondaryButton(
                label: 'Đánh giá hành trình',
                onPressed: _openReview,
                borderColor: const Color(0xFFE8620A),
                textColor: const Color(0xFFE8620A),
              ),
              const SizedBox(height: 8),
              TrekkingSecondaryButton(
                label: 'Xem lại bản đồ',
                onPressed: _openMap,
              ),
            ],
            // Cancel option (PLANNED or PAUSED)
            if (status == 'PLANNED' || status == 'PAUSED') ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _handleCancel,
                child: const Text('Hủy hành trình',
                    style: TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
