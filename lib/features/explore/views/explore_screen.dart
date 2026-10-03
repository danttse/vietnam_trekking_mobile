import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/cards/featured_place_card.dart';
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

  const ExploreScreen({
    super.key,
    this.onTrailTap,
    this.onPlaceTap,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreViewModel _viewModel;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;

  static const List<String> _regions = [
    'Miền Bắc',
    'Miền Trung',
    'Miền Nam',
    'Phổ biến',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ExploreViewModel();
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({
    required String title,
    VoidCallback? onSeeAll,
  }) {
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
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSlider(List<ExplorePlaceModel> places) {
    final colorScheme = Theme.of(context).colorScheme;

    if (places.isEmpty) {
      return _buildEmptyState('Không có địa điểm nổi bật phù hợp');
    }

    if (_currentPage >= places.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentPage = 0);
        _pageController.jumpToPage(0);
      });
    }

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            itemCount: places.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final place = places[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FeaturedPlaceCard(
                  place: place,
                  onTap: () => widget.onPlaceTap?.call(place),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(places.length, (index) {
            final active = _currentPage == index;
            //giong container nhung ma co them duration
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
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
                items: _regions,
                selectedIndex: _viewModel.selectedRegion,
                onSelect: _viewModel.setRegion,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
              title: l10n.featuredDestinations,
              onSeeAll: () {},
            ),
            const SizedBox(height: 10),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) =>
                  _buildFeaturedSlider(_viewModel.featuredPlaces),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
              title: l10n.popularTrails,
              onSeeAll: () {},
            ),
            const SizedBox(height: 10),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final trails = _viewModel.popularTrails;
                if (trails.isEmpty) {
                  return _buildEmptyState('Không có cung đường phù hợp');
                }
                return SizedBox(
                  height: 155,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trails.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
