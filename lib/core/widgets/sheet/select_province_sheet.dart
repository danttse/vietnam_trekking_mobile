import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/home/viewmodel/home_view_model.dart';
import '../../../features/home/data/province_model.dart';
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

  bool get _hasChanged => !setEquals(_initialVisitedIds, _tempVisitedIds);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _tempVisitedIds = widget.homeViewModel.visitedProvinces
        .map((p) => p.id)
        .toSet();
    _initialVisitedIds = Set.from(_tempVisitedIds);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    widget.homeViewModel.getListNorthernProvinces,
                  ),
                  _buildProvinceList(
                    _tabController.index == 1 ? scrollController : null,
                    widget.homeViewModel.getListCentralnProvinces,
                  ),
                  _buildProvinceList(
                    _tabController.index == 2 ? scrollController : null,
                    widget.homeViewModel.getListSouththernProvinces,
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
                      backgroundColor: _hasChanged
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      disabledBackgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _hasChanged
                        ? () {
                            widget.homeViewModel.updateVisitedProvinces(_tempVisitedIds);
                            Navigator.pop(context);
                          }
                        : null,
                    child: Text(
                      l10n.saveButton,
                      style: TextStyle(
                        color: _hasChanged
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: showProvinces.length,
      itemBuilder: (context, index) {
        final province = showProvinces[index];
        final isVisited = _tempVisitedIds.contains(province.id);
        return CheckboxListTile(
          value: isVisited,
          title: Text(province.name),
          activeColor: Colors.green,
          onChanged: (value) {
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