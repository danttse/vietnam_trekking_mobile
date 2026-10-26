import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../viewmodels/checkin_viewmodel.dart';
import '../data/models/milestone_model.dart';
import '../data/services/checkin_service.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import 'checkin_success_screen.dart';

class CheckinScreen extends StatefulWidget {
  final MilestoneModel milestone;
  final String journeyId; // localJourneyId
  final String userId; // từ auth state — không hard-code

  const CheckinScreen({
    super.key,
    required this.milestone,
    required this.journeyId,
    required this.userId,
  });

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen>
    with SingleTickerProviderStateMixin {
  late final CheckinViewModel _vm;
  late final CheckinService _checkinService;
  late final AnimationController _pulseCtrl;

  StreamSubscription<Position>? _locationSub;
  bool _locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _vm = CheckinViewModel(milestone: widget.milestone);
    _vm.addListener(_onVmChange);
    _checkinService = CheckinService();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startLocationTracking();
  }

  // ── Location tracking ─────────────────────────────────────────────────────

  Future<void> _startLocationTracking() async {
    // Kiểm tra và xin quyền vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        setState(() => _locationPermissionDenied = true);
      }
      return;
    }

    // Lấy vị trí một lần ngay lập tức để có dữ liệu ban đầu
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted)
        _vm.updateLocation(pos.latitude, pos.longitude, pos.accuracy);
    } catch (_) {
      /* ignore — stream sẽ cập nhật tiếp */
    }

    // Subscribe stream liên tục
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // cập nhật mỗi 3m
    );
    _locationSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
          if (mounted)
            _vm.updateLocation(pos.latitude, pos.longitude, pos.accuracy);
        });
  }

  // ── ViewModel listener ────────────────────────────────────────────────────

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.submitState == CheckinSubmitState.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CheckinSuccessScreen(milestone: widget.milestone),
        ),
      );
    } else if (_vm.submitState == CheckinSubmitState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.error ?? 'Check-in thất bại'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () {
              _vm.reset();
              _performCheckin();
            },
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Checkin action ────────────────────────────────────────────────────────

  Future<void> _performCheckin() async {
    await _vm.performCheckin(({
      required String milestoneId,
      required double latitude,
      required double longitude,
      required double accuracy,
      required double distanceToTarget,
    }) async {
      // Gọi CheckinService → POST /checkins tới checkin-service
      final result = await _checkinService.performCheckin(
        localJourneyId: widget.journeyId,
        milestoneId: milestoneId,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracy,
        distanceToTarget: distanceToTarget,
        userId: widget.userId,
      );

      // Trả về Map để CheckinViewModel lưu vào checkinResult
      return {
        'serverCheckinId': result.serverCheckinId,
        'milestoneType': result.milestoneType,
        'qualifiesPlaceVisit': result.qualifiesPlaceVisit,
        'verificationStatus': result.verificationStatus,
        'milestoneName': widget.milestone.name,
        'altitude': widget.milestone.altitude,
        ...result.raw,
      };
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inRange = _vm.gpsState == CheckinGpsState.inRange;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Check-in cột mốc',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
      body: _locationPermissionDenied
          ? _buildPermissionDenied(cs)
          : Column(
              children: [
                // ── GPS status chip ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        _vm.gpsState == CheckinGpsState.acquiring
                            ? Icons.gps_not_fixed
                            : Icons.gps_fixed,
                        size: 14,
                        color: _vm.gpsState == CheckinGpsState.acquiring
                            ? cs.onSurfaceVariant
                            : const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _vm.gpsState == CheckinGpsState.acquiring
                            ? 'GPS: Đang xác định vị trí...'
                            : 'GPS: Đã kết nối vị trí',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Radar ─────────────────────────────────────────────────
                Expanded(child: Center(child: _buildRadar(cs, inRange))),

                // ── Milestone info ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ĐIỂM CẦN ĐẾN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.milestone.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              widget.milestone.altitudeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Status message ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: inRange
                          ? const Color(0xFF1A3B2A)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: inRange
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                            : cs.onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          inRange
                              ? Icons.check_circle_outline
                              : Icons.info_outline,
                          size: 16,
                          color: inRange
                              ? const Color(0xFF4CAF50)
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            inRange
                                ? 'Bạn đang trong phạm vi check-in! (Cách ${_vm.distanceLabel})'
                                : 'Cần ở trong vòng bán kính '
                                      '${widget.milestone.checkinRadiusMeters.toInt()}m. '
                                      'Khoảng cách hiện tại: ${_vm.distanceLabel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: inRange
                                  ? const Color(0xFF81C784)
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── CTA button ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: BtnLoginPrimary(
                    text: 'Check-in ngay',
                    isLoading: _vm.submitState == CheckinSubmitState.submitting,
                    onPressed: _vm.canCheckin ? _performCheckin : null,
                  ),
                ),

                SafeArea(child: const SizedBox(height: 16)),
              ],
            ),
    );
  }

  Widget _buildPermissionDenied(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Không có quyền truy cập vị trí',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ứng dụng cần quyền vị trí để xác nhận bạn đang ở gần cột mốc.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text('Mở cài đặt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadar(ColorScheme cs, bool inRange) {
    final radarColor = inRange
        ? const Color(0xFF4CAF50)
        : const Color(0xFF2E4A2E);

    return SizedBox(
      width: 260,
      height: 260,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(
              progress: _pulseCtrl.value,
              color: radarColor,
              inRange: inRange,
              distanceFraction: _distanceFraction,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Milestone dot (centre)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8620A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8620A)
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.milestone.name.length > 12
                          ? '${widget.milestone.name.substring(0, 12)}...'
                          : widget.milestone.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // User dot
                if (_vm.gpsState != CheckinGpsState.acquiring)
                  Positioned(
                    right: 50 + (_distanceFraction * 60),
                    bottom: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: inRange
                                ? const Color(0xFF4CAF50)
                                : cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        Text(
                          'Bạn\n(${_vm.distanceLabel})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  double get _distanceFraction {
    final dist =
        _vm.distanceToTarget ?? widget.milestone.checkinRadiusMeters * 2;
    final radius = widget.milestone.checkinRadiusMeters;
    return (dist / (radius * 4)).clamp(0.0, 1.0);
  }
}

// ── Radar CustomPainter ───────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool inRange;
  final double distanceFraction;

  const _RadarPainter({
    required this.progress,
    required this.color,
    required this.inRange,
    required this.distanceFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // Background rings
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        maxR * i / 3,
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Check-in radius boundary
    canvas.drawCircle(
      center,
      maxR * 0.5,
      Paint()
        ..color = inRange
            ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
            : Colors.redAccent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Pulse
    canvas.drawCircle(
      center,
      maxR * 0.5 * (0.8 + progress * 0.4),
      Paint()
        ..color = color.withValues(alpha: (1 - progress) * 0.15)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress || old.inRange != inRange;
}
