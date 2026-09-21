import 'package:flutter/material.dart';
import '../../../features/home/viewmodel/home_view_model.dart';
import '../../../features/home/data/province_model.dart';

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
  Set<int> _tempVisitedIds = {};

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tỉnh thành đã đi',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(
                  height: 0.5,
                  color: Colors.grey,),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Miền Bắc'),
                    Tab(text: 'Miền Trung'),
                    Tab(text: 'Miền Nam'),
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
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          widget.homeViewModel.updateVisitedProvinces(_tempVisitedIds);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Lưu',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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