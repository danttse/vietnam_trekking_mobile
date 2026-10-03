import 'package:flutter/material.dart';
import '../viewmodels/create_journey_viewmodel.dart';
import '../data/models/route_model.dart';
import 'widgets/trekking_button.dart';

class CreateJourneyScreen extends StatefulWidget {
  const CreateJourneyScreen({super.key});

  @override
  State<CreateJourneyScreen> createState() => _CreateJourneyScreenState();
}

class _CreateJourneyScreenState extends State<CreateJourneyScreen> {
  late final CreateJourneyViewModel _vm;
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _memberCtrl = TextEditingController(text: '5');
  final _formKey = GlobalKey<FormState>();

  // Mock available routes — sẽ thay bằng API khi có màn Explore tích hợp
  final List<RouteModel> _mockRoutes = [
    RouteModel(
      routeId: 'route-ta-nang',
      trekkingPlaceId: 'place-ta-nang',
      name: 'Tà Năng - Phan Dũng',
      difficulty: 'HARD',
      distanceMeters: 28000,
      estimatedDurationMinutes: 4320,
      placeName: 'Lâm Đồng - Bình Thuận',
    ),
    RouteModel(
      routeId: 'route-fansipan',
      trekkingPlaceId: 'place-fansipan',
      name: 'Chinh phục Fansipan',
      difficulty: 'HARD',
      distanceMeters: 28000,
      estimatedDurationMinutes: 4320,
      placeName: 'Lào Cai',
    ),
    RouteModel(
      routeId: 'route-hagiang',
      trekkingPlaceId: 'place-hagiang',
      name: 'Hà Giang Loop',
      difficulty: 'MEDIUM',
      distanceMeters: 180000,
      estimatedDurationMinutes: 7200,
      placeName: 'Hà Giang',
    ),
    RouteModel(
      routeId: 'route-bacma',
      trekkingPlaceId: 'place-bacma',
      name: 'Bạch Mã',
      difficulty: 'MEDIUM',
      distanceMeters: 20000,
      estimatedDurationMinutes: 2880,
      placeName: 'Thừa Thiên Huế',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _vm = CreateJourneyViewModel();
    _vm.addListener(_onVmChange);
  }

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.state == CreateJourneyState.success) {
      Navigator.of(context).pop(true);
    } else if (_vm.state == CreateJourneyState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.error ?? 'Đã xảy ra lỗi'),
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
    _memberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_vm.plannedStartAt ?? now)
          : (_vm.plannedEndAt ?? now.add(const Duration(days: 3))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: const Color(0xFFE8620A),
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _vm.plannedStartAt = picked;
        } else {
          _vm.plannedEndAt = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _vm.name = _nameCtrl.text;
    _vm.notes = _noteCtrl.text;
    _vm.memberCount = int.tryParse(_memberCtrl.text);
    _vm.createJourney();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = _vm.state == CreateJourneyState.creating;

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
          'Tạo hành trình mới',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Tên chuyến đi ──────────────────────────────────────────────
            _SectionLabel('TÊN CHUYẾN ĐI'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: _inputDeco(cs, 'Chinh phục Tây Bắc huyền thoại'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
            ),

            const SizedBox(height: 20),
            // ── Ngày bắt đầu / kết thúc ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('NGÀY BẮT ĐẦU'),
                      const SizedBox(height: 8),
                      _DateButton(
                        date: _vm.plannedStartAt,
                        onTap: () => _pickDate(true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('NGÀY KẾT THÚC'),
                      const SizedBox(height: 8),
                      _DateButton(
                        date: _vm.plannedEndAt,
                        onTap: () => _pickDate(false),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // ── Chọn cung đường ────────────────────────────────────────────
            _SectionLabel('CHỌN CUNG ĐƯỜNG'),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _mockRoutes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final r = _mockRoutes[i];
                  final sel = _vm.selectedRouteId == r.routeId;
                  return GestureDetector(
                    onTap: () => setState(() => _vm.selectRoute(r)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFFE8620A).withValues(alpha: 0.15)
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFFE8620A)
                              : cs.onSurface.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sel) ...[
                            const Icon(Icons.check_circle,
                                size: 12,
                                color: Color(0xFFE8620A)),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            r.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? const Color(0xFFE8620A)
                                  : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_vm.selectedRoute != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_vm.selectedRoute!.distanceLabel}  ·  ${_vm.selectedRoute!.durationLabel}  ·  ${_vm.selectedRoute!.difficultyLabel}',
                  style:
                      TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
            ],

            const SizedBox(height: 20),
            // ── Số người tham gia ──────────────────────────────────────────
            _SectionLabel('SỐ NGƯỜI THAM GIA'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memberCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: _inputDeco(cs, '5 người'),
            ),

            const SizedBox(height: 20),
            // ── Ghi chú / Mô tả ───────────────────────────────────────────
            _SectionLabel('GHI CHÚ / MÔ TẢ'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 4,
              style: TextStyle(color: cs.onSurface, fontSize: 13),
              decoration: _inputDeco(
                cs,
                'Chuẩn bị đầy đủ lều trại, đồ ăn do thời tiết vùng cao khá lạnh về đêm...',
              ),
            ),

            const SizedBox(height: 20),
            // ── Bật tính năng Check-in ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bật tính năng Check-in',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tự động lưu dấu chân và mở khóa thư viện khi điểm đến.',
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _vm.enableCheckin,
                    onChanged: (v) =>
                        setState(() => _vm.enableCheckin = v),
                    activeThumbColor: const Color(0xFFE8620A),
                    activeTrackColor:
                        const Color(0xFFE8620A).withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            TrekkingPrimaryButton(
              label: 'Tạo hành trình',
              loading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(ColorScheme cs, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  const _DateButton({this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = date != null
        ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
        : 'DD/MM/YYYY';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: date != null
                        ? cs.onSurface
                        : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
