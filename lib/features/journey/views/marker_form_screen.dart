import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../viewmodels/marker_form_viewmodel.dart';
import '../data/models/marker_model.dart';
import 'widgets/trekking_button.dart';

/// Compact marker sheet leaves the route visible above it.
class MarkerFormScreen extends StatefulWidget {
  final String localJourneyId, userId;
  final double? initialLat, initialLng, initialAlt, initialAccuracy;
  final MarkerModel? editingMarker;
  final void Function(MarkerModel)? onMarkerSaved;
  final MarkerFormViewModel? viewModel;
  const MarkerFormScreen({
    super.key,
    required this.localJourneyId,
    required this.userId,
    this.initialLat,
    this.initialLng,
    this.initialAlt,
    this.initialAccuracy,
    this.editingMarker,
    this.onMarkerSaved,
    this.viewModel,
  });
  @override
  State<MarkerFormScreen> createState() => _MarkerFormScreenState();
}

class _MarkerFormScreenState extends State<MarkerFormScreen> {
  late final MarkerFormViewModel _vm;
  final _nameCtrl = TextEditingController(),
      _noteCtrl = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _picking = false;
  @override
  void initState() {
    super.initState();
    _vm =
        widget.viewModel ??
        MarkerFormViewModel(
          localJourneyId: widget.localJourneyId,
          userId: widget.userId,
          editingMarker: widget.editingMarker,
        );
    _nameCtrl.text = _vm.name;
    _noteCtrl.text = _vm.note;
    final marker = widget.editingMarker;
    if (marker != null) {
      _vm.setLocation(marker.latitude, marker.longitude, alt: marker.altitude);
    } else if (widget.initialLat != null && widget.initialLng != null) {
      _vm.setLocation(
        widget.initialLat!,
        widget.initialLng!,
        alt: widget.initialAlt,
        acc: widget.initialAccuracy,
      );
    }
    _vm.addListener(_onChange);
  }

  void _onChange() {
    if (!mounted) return;
    if (_vm.state == MarkerFormState.success && _vm.savedMarker != null) {
      widget.onMarkerSaved?.call(_vm.savedMarker!);
      Navigator.pop(context, _vm.savedMarker);
      return;
    }
    if (_vm.state == MarkerFormState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _vm.error ?? 'Không lưu được cột mốc. Vui lòng thử lại.',
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onChange);
    if (widget.viewModel == null) _vm.dispose();
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_picking || _vm.state == MarkerFormState.saving) return;
    final slots = 5 - _vm.mediaLocalPaths.length - _vm.mediaRemoteUrls.length;
    if (slots <= 0) return;
    setState(() => _picking = true);
    try {
      final photos = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (!mounted || photos.isEmpty) return;
      final root = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(root.path, 'marker_photos'));
      await directory.create(recursive: true);
      for (final photo in photos.take(slots)) {
        final target = p.join(
          directory.path,
          '${DateTime.now().microsecondsSinceEpoch}_${p.basename(photo.path)}',
        );
        await File(photo.path).copy(target);
        if (!mounted) return;
        _vm.addImage(target);
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không chọn được ảnh. Vui lòng thử lại.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _save(bool sync) {
    if (!_form.currentState!.validate()) return;
    _vm.name = _nameCtrl.text;
    _vm.note = _noteCtrl.text;
    _vm.save(syncImmediately: sync);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final saving = _vm.state == MarkerFormState.saving;
    return PopScope(
      canPop: !saving,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: MediaQuery.viewInsetsOf(context).bottom > 0
                ? .92
                : .57,
            minChildSize: .45,
            maxChildSize: .92,
            expand: false,
            builder: (_, scroll) => SafeArea(
              top: false,
              child: Form(
                key: _form,
                child: ListView(
                  controller: scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.flag_outlined, color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _vm.isEditing
                                ? 'Chỉnh sửa cột mốc'
                                : 'Đánh dấu cột mốc',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: saving
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    Text(
                      'Lưu cột mốc riêng, sau đó chọn “Gửi cho admin” trên bản đồ để đóng góp điểm này.',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _label('TÊN CỘT MỐC *', cs),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      enabled: !saving,
                      maxLength: 200,
                      textInputAction: TextInputAction.next,
                      scrollPadding: const EdgeInsets.all(32),
                      style: const TextStyle(fontSize: 13),
                      decoration: _deco(
                        cs,
                        'Cột mốc mới',
                      ).copyWith(counterText: ''),
                      validator: (value) => value?.trim().isNotEmpty == true
                          ? null
                          : 'Nhập tên cột mốc',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('LOẠI *', cs),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _vm.selectedType,
                                isExpanded: true,
                                decoration: _deco(cs, ''),
                                items: MarkerFormViewModel.markerTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type['value'],
                                        child: Text(
                                          type['label']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: saving
                                    ? null
                                    : (v) {
                                        if (v != null) _vm.setType(v);
                                      },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('TỌA ĐỘ GPS', cs),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${_vm.latitude?.toStringAsFixed(5) ?? '--'}, ${_vm.longitude?.toStringAsFixed(5) ?? '--'}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _label('ẢNH MINH HỌA • TỐI ĐA 5 ẢNH', cs),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 64,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          InkWell(
                            onTap: saving || _picking ? null : _pickImages,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 64,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: _picking
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 22,
                                          color: cs.primary,
                                        ),
                                        const Text(
                                          'Thêm ảnh',
                                          style: TextStyle(fontSize: 9),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          for (final path in _vm.mediaLocalPaths)
                            _photo(
                              Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.broken_image_outlined),
                              ),
                              onRemove: saving
                                  ? null
                                  : () => _vm.removeImage(path),
                            ),
                          for (final url in _vm.mediaRemoteUrls)
                            _photo(
                              Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.broken_image_outlined),
                              ),
                              onRemove: saving
                                  ? null
                                  : () => _vm.removeRemoteImage(url),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _label('GHI CHÚ', cs)),
                        Text(
                          '${_noteCtrl.text.length}/350',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteCtrl,
                      enabled: !saving,
                      maxLines: 2,
                      maxLength: 350,
                      scrollPadding: const EdgeInsets.all(32),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 12),
                      decoration: _deco(
                        cs,
                        'Cảnh đẹp, bãi nghỉ, nguồn nước…',
                      ).copyWith(counterText: ''),
                    ),
                    if (_vm.accuracy != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'GPS ±${_vm.accuracy!.round()} m • cao độ ${_vm.altitude?.round() ?? '--'} m',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TrekkingSecondaryButton(
                            label: 'Lưu trên máy',
                            onPressed: saving || _picking
                                ? null
                                : () => _save(false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TrekkingPrimaryButton(
                            label: 'Lưu & đồng bộ',
                            loading: saving,
                            onPressed: saving || _picking
                                ? null
                                : () => _save(true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đồng bộ lưu cột mốc vào tài khoản. Chọn “Gửi cho admin” để gửi xét duyệt.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _photo(Widget image, {VoidCallback? onRemove}) => Container(
    width: 72,
    margin: const EdgeInsets.only(right: 8),
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
      ],
    ),
  );
  Widget _label(String text, ColorScheme cs) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: cs.onSurfaceVariant,
    ),
  );
  InputDecoration _deco(ColorScheme cs, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
    filled: true,
    fillColor: cs.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  );
}
