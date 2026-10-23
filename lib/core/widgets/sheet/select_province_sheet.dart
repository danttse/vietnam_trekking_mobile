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

  Future<void> _onSave() async {
    if (!_canSave) return;

    final added = _tempVisitedIds.difference(_initialVisitedIds);
    final removed = _initialVisitedIds.difference(_tempVisitedIds);

    setState(() => _isSaving = true);

    try {
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
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: showProvinces.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final province = showProvinces[index];
        final isVisited = _tempVisitedIds.contains(province.id);
        return GestureDetector(
          onTap: _isSaving
              ? null
              : () {
                  setState(() {
                    if (isVisited) {
                      _tempVisitedIds.remove(province.id);
                    } else {
                      _tempVisitedIds.add(province.id);
                    }
                  });
                },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVisited
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isVisited
                  ? Border.all(color: colorScheme.primary, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.terrain,
                    size: 24,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        province.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        province.region,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
