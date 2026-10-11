import 'package:flutter/material.dart';

import '../../../features/route/data/models/route_model.dart';
import '../../services/trekking_catalog_service.dart';
import '../cards/route_card.dart';
import 'app_draggable_sheet.dart';

/// Routes are fetched only after the user opens a place, never flattened across
/// unrelated places. Back returns to the place list without selecting a route.
class SelectRouteSheet extends StatefulWidget {
  final List<RouteModel> routes;
  final List<Map<String, dynamic>>? places;
  final RouteModel? selectedRoute;
  final ValueChanged<RouteModel> onRouteSelected;
  final TrekkingCatalogService? catalog;
  const SelectRouteSheet({
    super.key,
    required this.routes,
    this.places,
    this.selectedRoute,
    required this.onRouteSelected,
    this.catalog,
  });
  @override
  State<SelectRouteSheet> createState() => _SelectRouteSheetState();
}

class _SelectRouteSheetState extends State<SelectRouteSheet> {
  late final TrekkingCatalogService _catalog;
  List<Map<String, dynamic>> _places = [];
  List<RouteModel> _routes = [];
  Map<String, dynamic>? _place;
  String _query = '';
  bool _loading = false;
  String? _error;
  int _request = 0;
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog ?? TrekkingCatalogService();
    if (widget.places?.isNotEmpty == true) {
      _places = widget.places!;
    } else {
      _loadPlaces();
    }
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final places = await _catalog.getPlaces();
      if (mounted) setState(() => _places = places);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải địa điểm.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPlace(Map<String, dynamic> place) async {
    final request = ++_request;
    setState(() {
      _place = place;
      _routes = [];
      _loading = true;
      _error = null;
      _query = '';
      _search.clear();
    });
    try {
      final id = (place['trekkingPlaceId'] ?? place['_id']).toString();
      final routes = await _catalog.getRoutes(id, place: place);
      if (mounted && request == _request) setState(() => _routes = routes);
    } catch (_) {
      if (mounted && request == _request)
        setState(() => _error = 'Không thể tải cung đường tại địa điểm này.');
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  void _back() {
    ++_request;
    setState(() {
      _place = null;
      _routes = [];
      _loading = false;
      _error = null;
      _query = '';
      _search.clear();
    });
  }

  @override
  void dispose() {
    ++_request;
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final places = _places
        .where(
          (p) => (p['name'] ?? '').toString().toLowerCase().contains(
            _query.toLowerCase(),
          ),
        )
        .toList();
    final routes = _routes
        .where((r) => r.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return AppDraggableSheet(
      title: _place == null
          ? 'Chọn địa điểm'
          : 'Cung đường tại ${_place!['name']}',
      initialChildSize: .7,
      minChildSize: .4,
      maxChildSize: .95,
      contentBuilder: (context, scroll) => Column(
        children: [
          if (_place != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Đổi địa điểm'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: _place == null ? 'Tìm địa điểm' : 'Tìm cung đường',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        TextButton(
                          onPressed: _place == null
                              ? _loadPlaces
                              : () => _openPlace(_place!),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : (_place == null ? places.isEmpty : routes.isEmpty)
                ? Center(
                    child: Text(
                      _place == null
                          ? 'Chưa có địa điểm.'
                          : 'Địa điểm này chưa có cung đường.',
                    ),
                  )
                : _place == null
                ? ListView.separated(
                    controller: scroll,
                    itemCount: places.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => ListTile(
                      leading: Icon(
                        Icons.landscape_outlined,
                        color: colors.primary,
                      ),
                      title: Text(places[i]['name'].toString()),
                      subtitle: Text((places[i]['address'] ?? '').toString()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openPlace(places[i]),
                    ),
                  )
                : ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: routes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => RouteCard(
                      route: routes[i],
                      isSelected:
                          widget.selectedRoute?.routeId == routes[i].routeId,
                      onTap: () {
                        widget.onRouteSelected(routes[i]);
                        Navigator.pop(context);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
