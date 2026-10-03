import 'package:flutter/material.dart';
import '../../../features/route/data/models/route_model.dart';
import '../../../l10n/app_localizations.dart';
import '../cards/route_card.dart';
import 'app_draggable_sheet.dart';

class SelectRouteSheet extends StatefulWidget {
  final List<RouteModel> routes;
  final RouteModel? selectedRoute;
  final ValueChanged<RouteModel> onRouteSelected;

  const SelectRouteSheet({
    super.key,
    required this.routes,
    this.selectedRoute,
    required this.onRouteSelected,
  });

  @override
  State<SelectRouteSheet> createState() => _SelectRouteSheetState();
}

class _SelectRouteSheetState extends State<SelectRouteSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RouteModel> get _filteredRoutes {
    if (_searchQuery.isEmpty) return widget.routes;
    return widget.routes.where((r) {
      final name = r.name.toLowerCase();
      final province = (r.province ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || province.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final routes = _filteredRoutes;

    return AppDraggableSheet(
      title: l10n.selectRouteSheetTitle,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      contentBuilder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.trim()),
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.searchTrailsPlaces,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: colorScheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: routes.isEmpty
                  ? Center(
                      child: Text(
                        l10n.selectRouteHint,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: routes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final route = routes[index];
                        final isSelected =
                            widget.selectedRoute?.routeId == route.routeId;

                        return RouteCard(
                          route: route,
                          isSelected: isSelected,
                          onTap: () {
                            widget.onRouteSelected(route);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
