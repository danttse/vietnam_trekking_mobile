import 'package:flutter/material.dart';

import '../viewmodels/contribution_viewmodel.dart';
import '../data/models/journey_model.dart';
import '../data/models/marker_model.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/services/journey_track.dart';

/// Màn hình submit Route Contribution sau khi hoàn thành hành trình.
///
/// Luồng: CompleteJourney → dialog hỏi "Đóng góp cung đường?" → ContributionScreen
class ContributionScreen extends StatefulWidget {
  final JourneyModel journey;
  final List<MarkerModel> markers;
  final String userId;
  final bool markerOnly;

  const ContributionScreen({
    super.key,
    required this.journey,
    required this.markers,
    required this.userId,
    this.markerOnly = false,
  });

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  late final ContributionViewModel _vm;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _vm = ContributionViewModel(
      userId: widget.userId,
      markerOnly: widget.markerOnly,
    );
    _vm.addListener(_onVmChange);

    // Pre-fill tên từ journey
    _nameCtrl.text = widget.journey.name;
    _vm.setProposedName(widget.journey.name);
    _vm.selectedMarkerIds = widget.markers
        .map((m) => m.serverMarkerId ?? m.markerId)
        .toList();
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.submitState == ContributionSubmitState.success ||
        _vm.submitState == ContributionSubmitState.queued) {
      _showSuccessAndPop();
    } else if (_vm.submitState == ContributionSubmitState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.error ?? 'Gửi đóng góp thất bại'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    setState(() {});
  }

  Future<void> _showSuccessAndPop() async {
    if (!mounted) return;
    final queued = _vm.submitState == ContributionSubmitState.queued;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(queued ? 'Đã lưu đóng góp' : 'Đã gửi đóng góp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              queued
                  ? 'App sẽ tự gửi khi có mạng. Admin sẽ nhận được sau khi đồng bộ thành công.'
                  : widget.markerOnly
                  ? 'Admin đã nhận các cột mốc bạn chọn.'
                  : 'Admin đã nhận cung đường và các cột mốc bạn chọn.',
            ),
            const SizedBox(height: 8),
            Text(
              queued
                  ? 'Trạng thái: Chờ đồng bộ'
                  : 'Trạng thái: ${_vm.submittedContribution?.statusLabel ?? "Chờ xét duyệt"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bạn có thể xem trạng thái trong lịch sử đóng góp.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // back from contribution screen
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8620A),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _vm.setProposedName(_nameCtrl.text.trim());
    _vm.setDescription(_descCtrl.text.trim());
    _vm.setNotes(_notesCtrl.text.trim());
    await _vm.submitRouteContribution(widget.journey);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final submitting = _vm.submitState == ContributionSubmitState.submitting;

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
          widget.markerOnly ? 'Gửi cột mốc cho admin' : 'Đóng góp cung đường',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Info banner ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3B2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF81C784),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.markerOnly
                          ? 'Chọn cột mốc để gửi admin xét duyệt. Bạn có thể gửi ngay trong hành trình; tọa độ, ảnh và ghi chú của các điểm đã chọn sẽ được đính kèm.'
                          : 'Dữ liệu GPS từ hành trình của bạn sẽ giúp cộng đồng trekker tìm đường '
                                'tốt hơn. Đội ngũ sẽ xem xét và phê duyệt trước khi đăng tải.',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF81C784).withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Hành trình nguồn ────────────────────────────────────────
            _sectionLabel('HÀNH TRÌNH NGUỒN', cs),
            const SizedBox(height: 8),
            _infoRow(
              cs,
              icon: Icons.route,
              label: widget.journey.name,
              sub: _journeySub(),
            ),
            if (!widget.markerOnly)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  JourneyTrack.decode(
                            widget.journey.encodedPolyline ?? '',
                            widget.journey.journeyId,
                          ).length >=
                          2
                      ? 'Đính kèm đường GPS đã lưu và ${widget.journey.pendingSync ? "chờ đồng bộ hành trình trước khi gửi admin" : "gửi admin xét duyệt"}.'
                      : 'Hành trình chưa có đường GPS đã ghi. Hãy bật ghi lại đường đi trên màn map cho hành trình tiếp theo.',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),

            const SizedBox(height: 24),

            // ── Tên cung đường đề xuất ──────────────────────────────────
            _sectionLabel(
              widget.markerOnly ? 'TÊN ĐÓNG GÓP *' : 'TÊN CUNG ĐƯỜNG ĐỀ XUẤT *',
              cs,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              maxLength: 200,
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration(
                cs,
                'Ví dụ: Cung Langbiang qua rừng thông',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              onChanged: _vm.setProposedName,
            ),

            const SizedBox(height: 16),

            // ── Mô tả ───────────────────────────────────────────────────
            _sectionLabel('MÔ TẢ (tùy chọn)', cs),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 2000,
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration(cs, 'Mô tả đặc điểm cung đường...'),
              onChanged: _vm.setDescription,
            ),

            const SizedBox(height: 16),

            // ── Ghi chú ─────────────────────────────────────────────────
            _sectionLabel('GHI CHÚ AN TOÀN (tùy chọn)', cs),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              maxLength: 1000,
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration(
                cs,
                'Ví dụ: Dốc đứng đoạn km 8, cẩn thận mưa trơn...',
              ),
              onChanged: _vm.setNotes,
            ),

            // ── Chọn markers để share ──────────────────────────────────
            if (widget.markers.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionLabel('ĐIỂM ĐÃ ĐÁNH DẤU (chọn để chia sẻ)', cs),
              const SizedBox(height: 8),
              Text(
                'Tên, tọa độ, ảnh và ghi chú của các điểm đã chọn sẽ được gửi cho admin xét duyệt.',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              ..._buildMarkerCheckboxes(cs),
            ],

            const SizedBox(height: 32),

            // ── Submit button ───────────────────────────────────────────
            BtnLoginPrimary(
              text: 'Gửi đóng góp',
              isLoading: submitting,
              onPressed: _vm.canSubmit && !submitting ? _submit : null,
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Bỏ qua, về trang chủ',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<Widget> _buildMarkerCheckboxes(ColorScheme cs) {
    return widget.markers.map((m) {
      final id = m.serverMarkerId ?? m.markerId;
      final selected = _vm.selectedMarkerIds.contains(id);
      return CheckboxListTile(
        value: selected,
        onChanged: _vm.submitState == ContributionSubmitState.submitting
            ? null
            : (_) => _vm.toggleMarkerId(id),
        title: Text(
          m.name,
          style: TextStyle(fontSize: 13, color: cs.onSurface),
        ),
        subtitle: Text(
          m.typeLabel,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        secondary: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.place, size: 16, color: cs.onPrimaryContainer),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        dense: true,
        tileColor: selected
            ? const Color(0xFF1A3B2A)
            : cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    }).toList();
  }

  String _journeySub() {
    final j = widget.journey;
    final parts = <String>[];
    if (j.distanceMeters > 0) {
      parts.add('${(j.distanceMeters / 1000).toStringAsFixed(1)} km');
    }
    if (j.elevationGain > 0) {
      parts.add('+${j.elevationGain.toInt()}m');
    }
    return parts.join(' • ');
  }

  Widget _sectionLabel(String label, ColorScheme cs) => Text(
    label,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: cs.onSurfaceVariant,
      letterSpacing: 0.5,
    ),
  );

  Widget _infoRow(
    ColorScheme cs, {
    required IconData icon,
    required String label,
    String? sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (sub != null && sub.isNotEmpty)
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme cs, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFFE8620A), width: 1.5),
        ),
      );
}
