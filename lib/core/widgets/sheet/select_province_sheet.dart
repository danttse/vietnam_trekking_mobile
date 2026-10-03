import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/home/viewmodel/home_view_model.dart';
import '../../../features/home/data/province_model.dart';
import '../../../features/home/data/datasources/province_sample_data.dart';
import '../../../features/home/data/exceptions/province_exception.dart';
import 'app_draggable_sheet.dart';

class SelectProvinceSheet extends StatefulWidget {
  final HomeViewModel homeViewModel;

  const SelectProvinceSheet({
    super.key,
    required this.homeViewModel,
  });

  @override
  State<SelectProvinceSheet> createState() => _SelectProvinceSheetState();
}

class _SelectProvinceSheetState extends State<SelectProvinceSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> _tempVisitedIds = {};
  late final Set<String> _initialVisitedIds;

  bool _isSaving = false;

  // ── Danh sách 34 tỉnh cố định từ static local ─────────────────────────────
  // Không phụ thuộc vào homeViewModel.provinces (vốn thay đổi khi API load).
  static final List<Province> _northProvinces = ProvinceData.provinces
      .where((p) => p.region == Province.mienBac)
      .toList();
  static final List<Province> _centralProvinces = ProvinceData.provinces
      .where((p) => p.region == Province.mienTrung)
      .toList();
  static final List<Province> _southProvinces = ProvinceData.provinces
      .where((p) => p.region == Province.mienNam)
      .toList();

  bool get _hasChanged => !setEquals(_initialVisitedIds, _tempVisitedIds);
  bool get _canSave => _hasChanged && !_isSaving;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Lấy trạng thái đã đi từ homeViewModel (đã được load từ API)
    // dùng để pre-check các checkbox
    final visitedIds = widget.homeViewModel.visitedProvinces
        .map((p) => p.id)
        .toSet();
    _tempVisitedIds = Set.from(visitedIds);
    _initialVisitedIds = Set.from(visitedIds);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Save handler ──────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_canSave) return;

    // Tính diff: tỉnh nào được thêm mới (tick) và tỉnh nào bị bỏ (untick)
    final added = _tempVisitedIds.difference(_initialVisitedIds);
    final removed = _initialVisitedIds.difference(_tempVisitedIds);

    setState(() => _isSaving = true);

    try {
      // Gọi PATCH song song cho tất cả tỉnh thay đổi
      final futures = <Future<void>>[
        for (final code in added)
          widget.homeViewModel.setProvinceManualMark(
            provinceCode: code,
            visited: true,
          ),
        for (final code in removed)
          widget.homeViewModel.setProvinceManualMark(
            provinceCode: code,
            visited: false,
          ),
      ];
      await Future.wait(futures);

      // Cập nhật đồng bộ local state của HomeViewModel cho toàn bộ danh sách
      // (setProvinceManualMark đã update từng tỉnh riêng lẻ, dòng này
      //  đảm bảo các tỉnh không được PATCH vẫn nhất quán)
      widget.homeViewModel.updateVisitedProvinces(_tempVisitedIds);

      if (mounted) Navigator.pop(context);
    } on ProvinceException catch (e) {
      if (kDebugMode) {
        debugPrint('[SelectProvinceSheet] save error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SelectProvinceSheet] unexpected save error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã có lỗi xảy ra. Vui lòng thử lại'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppDraggableSheet(
      title: l10n.provinceSheetTitle,
      contentBuilder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.regionNorth),
                Tab(text: l10n.regionCentral),
                Tab(text: l10n.regionSouth),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProvinceList(
                    _tabController.index == 0 ? scrollController : null,
                    _northProvinces,
                  ),
                  _buildProvinceList(
                    _tabController.index == 1 ? scrollController : null,
                    _centralProvinces,
                  ),
                  _buildProvinceList(
                    _tabController.index == 2 ? scrollController : null,
                    _southProvinces,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: _canSave
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      disabledBackgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _canSave ? _onSave : null,
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            l10n.saveButton,
                            style: TextStyle(
                              color: _canSave
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.4),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProvinceList(
    ScrollController? scrollController,
    List<Province> showProvinces,
  ) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: showProvinces.length,
      itemBuilder: (context, index) {
        final province = showProvinces[index];
        final isVisited = _tempVisitedIds.contains(province.id);
        return CheckboxListTile(
          value: isVisited,
          title: Text(province.name),
          activeColor: Colors.green,
          // Không cho phép thay đổi khi đang save
          onChanged: _isSaving
              ? null
              : (value) {
                  setState(() {
                    if (isVisited) {
                      _tempVisitedIds.remove(province.id);
                    } else {
                      _tempVisitedIds.add(province.id);
                    }
                  });
                },
          controlAffinity: ListTileControlAffinity.trailing,
        );
      },
    );
  }
}
