import 'package:flutter/material.dart';

import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/cards/featured_place_card.dart';
import '../../../core/widgets/carousels/paged_carousel.dart';
import '../../../core/widgets/cards/popular_trail_card.dart';
import '../../../core/widgets/cards/recommended_place_card.dart';
import '../../../core/widgets/chips/horizontal_chip_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/explore_place_model.dart';
import '../data/models/popular_trail_model.dart';
import '../viewmodel/explore_view_model.dart';

class ExploreScreen extends StatefulWidget {
  final ValueChanged<PopularTrailModel>? onTrailTap;
  final ValueChanged<ExplorePlaceModel>? onPlaceTap;
  final ExploreViewModel? viewModel;

  const ExploreScreen({
    super.key,
    this.onTrailTap,
    this.onPlaceTap,
    this.viewModel,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ExploreViewModel();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 400 &&
          _viewModel.error == null) {
        _viewModel.loadMorePlaces();

      }
    });
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onSeeAll}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  l10n.seeAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchTrailsPlaces,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: _searchController.clear,
              );
            },
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSlider(List<ExplorePlaceModel> places) {
    if (places.isEmpty) {
      return _buildEmptyState('Không có địa điểm nổi bật phù hợp');
    }
    return PagedCarousel(
      key: ValueKey('featured:${places.map((place) => place.id).join(',')}'),
      height: 210,
      itemCount: places.length,
      autoAdvanceInterval: const Duration(seconds: 3),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FeaturedPlaceCard(
          place: places[index],
          onTap: () => widget.onPlaceTap?.call(places[index]),
        ),
      ),
    );
  }

  Widget _buildMoreTrailsTile() {
    final colors = Theme.of(context).colorScheme;
    final loading = _viewModel.isLoadingMoreTrails;
    return SizedBox(
      key: const ValueKey('more-trails-tile'),
      width: 140,
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: loading || _viewModel.isLoading
              ? null
              : _viewModel.loadMoreTrails,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _viewModel.routesError == null
                        ? Icons.arrow_forward_rounded
                        : Icons.refresh_rounded,
                    color: colors.primary,
                  ),
                const SizedBox(height: 8),
                Text(
                  loading
                      ? 'Đang tải…'
                      : _viewModel.routesError == null
                      ? 'Thêm cung đường'
                      : 'Thử lại',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _viewModel.refresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(title: l10n.navExplore),
              const SizedBox(height: 8),
              _buildSearchBar(),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => HorizontalChipBar(
                  items: ExploreFilter.values
                      .map((filter) => filter.label)
                      .toList(),
                  selectedIndex: _viewModel.selectedRegion,
                  onSelect: _viewModel.setRegion,
                ),
              ),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const LinearProgressIndicator();
                  }
                  if (_viewModel.error == null &&
                      _viewModel.routesError == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      Text(
                        _viewModel.error ??
                            'Không tải được một số cung đường: ${_viewModel.routesError}',
                      ),
                      TextButton(
                        onPressed: _viewModel.load,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(title: l10n.featuredDestinations),
              const SizedBox(height: 10),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) =>
                    _buildFeaturedSlider(_viewModel.featuredPlaces),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(title: l10n.popularTrails),
              const SizedBox(height: 10),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final trails = _viewModel.popularTrails;
                  if (trails.isEmpty) {
                    return _buildEmptyState('Không có cung đường phù hợp');
                  }
                  return SizedBox(
                    height:
                        120 +
                        MediaQuery.textScalerOf(context).scale(11) * 1.5 +
                        MediaQuery.textScalerOf(context).scale(9) * 1.5,
                    child: ListView.separated(
                      key: const ValueKey('popular-trails-list'),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          trails.length + (_viewModel.hasMoreTrails ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == trails.length) {
                          return _buildMoreTrailsTile();
                        }
                        final trail = trails[index];
                        return PopularTrailCard(
                          trail: trail,
                          onTap: () => widget.onTrailTap?.call(trail),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(title: l10n.recommendedForYou),
              const SizedBox(height: 10),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final recommended = _viewModel.recommendedPlaces;
                  if (recommended.isEmpty) {
                    return _buildEmptyState('Không có gợi ý phù hợp');
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recommended.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final place = recommended[index];
                      return RecommendedPlaceCard(
                        place: place,
                        onTap: () => widget.onPlaceTap?.call(place),
                      );
                    },
                  );
                },
              ),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => _viewModel.hasMorePlaces
                    ? Center(
                        child: TextButton(
                          onPressed: _viewModel.isLoadingMorePlaces
                              ? null
                              : _viewModel.loadMorePlaces,
                          child: Text(
                            _viewModel.isLoadingMorePlaces
                                ? 'Đang tải…'
                                : 'Thêm địa điểm',
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
