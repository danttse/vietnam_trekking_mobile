import 'package:flutter/material.dart';
import '../viewmodels/marker_form_viewmodel.dart';
import '../data/models/marker_model.dart';
import 'widgets/trekking_button.dart';

/// Bottom sheet form để tạo / chỉnh sửa Journey Marker.
class MarkerFormScreen extends StatefulWidget {
  final String localJourneyId;
  final String userId;
  final double? initialLat;
  final double? initialLng;
  final double? initialAlt;
  final MarkerModel? editingMarker;
  final void Function(MarkerModel)? onMarkerSaved;

  const MarkerFormScreen({
    super.key,
    required this.localJourneyId,
    required this.userId,
    this.initialLat,
    this.initialLng,
    this.initialAlt,
    this.editingMarker,
    this.onMarkerSaved,
  });

  @override
  State<MarkerFormScreen> createState() => _MarkerFormScreenState();
}

class _MarkerFormScreenState extends State<MarkerFormScreen> {
  late final MarkerFormViewModel _vm;
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = MarkerFormViewModel(
      localJourneyId: widget.localJourneyId,
      userId: widget.userId,
      editingMarker: widget.editingMarker,
    );
    if (widget.editingMarker != null) {
      _nameCtrl.text = widget.editingMarker!.name;
      _noteCtrl.text = widget.editingMarker!.note ?? '';
    }
    _vm.setLocation(
      widget.initialLat ?? 0,
      widget.initialLng ?? 0,
      alt: widget.initialAlt,
    );
    _vm.addListener(_onVmChange);
  }

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.state == MarkerFormState.success && _vm.savedMarker != null) {
      widget.onMarkerSaved?.call(_vm.savedMarker!);
      Navigator.of(context).pop(_vm.savedMarker);
    } else if (_vm.state == MarkerFormState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.error ?? 'Lỗi lưu cột mốc'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    _vm.name = _nameCtrl.text;
    _vm.note = _noteCtrl.text;
    _vm.save();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = _vm.state == MarkerFormState.saving;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          children: [
            // ── Handle ────────────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Header ────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8620A)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flag_outlined,
                      color: Color(0xFFE8620A), size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  _vm.isEditing
                      ? 'Chỉnh sửa cột mốc'
                      : 'Đánh dấu cột mốc',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              'Thêm thông tin và gửi cho admin để cùng hành trình.',
              style: TextStyle(
                  fontSize: 12, color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            // ── Name field ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('TÊN CỘT MỐC *'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        style: TextStyle(
                            color: cs.onSurface, fontSize: 14),
                        decoration: _deco(cs, 'Cột mốc mới'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Thumbnail placeholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('ẢNH MINH HOẠ'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {/* pick image */},
                      child: Container(
                        width: 72,
                        height: 52,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: cs.onSurface
                                  .withValues(alpha: 0.1)),
                        ),
                        child: Icon(Icons.add_photo_alternate_outlined,
                            color: cs.onSurfaceVariant, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Type selector ─────────────────────────────────────────
            _Label('LOẠI *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MarkerFormViewModel.markerTypes.map((t) {
                final sel = _vm.selectedType == t['value'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _vm.setType(t['value']!)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFE8620A)
                              .withValues(alpha: 0.15)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFE8620A)
                            : cs.onSurface.withValues(alpha: 0.1),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t['icon']!, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          t['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: sel
                                ? const Color(0xFFE8620A)
                                : cs.onSurface,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Note ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Label('GHI CHÚ'),
                Text('0/350',
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 350,
              style: TextStyle(color: cs.onSurface, fontSize: 13),
              decoration: _deco(
                      cs,
                      'View đẹp, cỏ lùi, thích hợp nghỉ trưa.')
                  .copyWith(counterText: ''),
            ),

            const SizedBox(height: 16),

            // ── GPS coords ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.gps_fixed,
                      size: 14, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    'TOẠ ĐỘ',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.initialLat?.toStringAsFixed(5) ?? '--'}, ${widget.initialLng?.toStringAsFixed(5) ?? '--'}',
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurface),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TrekkingSecondaryButton(
                    label: '🔒  Lưu cục bộ',
                    onPressed: isLoading
                        ? null
                        : () {
                            _vm.name = _nameCtrl.text;
                            _vm.note = _noteCtrl.text;
                            _vm.save();
                          },
                    loading: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TrekkingPrimaryButton(
                    label: '✈  Gửi admin',
                    onPressed: isLoading ? null : _save,
                    loading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(ColorScheme cs, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 13),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.4));
  }
}
