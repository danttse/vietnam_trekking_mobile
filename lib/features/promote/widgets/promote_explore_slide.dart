import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/chips/horizontal_chip_bar.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_slide_scaffold.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteExploreSlide extends StatefulWidget {
  const PromoteExploreSlide({super.key});

  @override
  State<PromoteExploreSlide> createState() => _PromoteExploreSlideState();
}

class _PromoteExploreSlideState extends State<PromoteExploreSlide> {
  int _selectedRegionIndex = 0;

  static const List<_PromoteExplorePlace> _places = [
    _PromoteExplorePlace(
      name: 'Tà Xùa',
      imageUrl:
          'https://vcdn1-dulich.vnecdn.net/2023/09/26/thaonguyen1-9546-1695723031.jpg?w=0&h=0&q=100&dpr=2&fit=crop&s=hPttIphPb7dr9bd_O6FZvg',
    ),
    _PromoteExplorePlace(
      name: 'Vườn quốc gia Bạch Mã',
      imageUrl:
          'https://www.lagunalangco.com/wp-content/uploads/2025/04/bach-ma-national-park-1-1024x575.jpg',
    ),
    _PromoteExplorePlace(
      name: 'Núi Chứa Chan',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWg5wx9HXwgX9lqKY-sLYcjH02wOJhNkINH45b-fnLtwLoSQnSNMIYTkw&s=10',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final regions = [
      l10n.regionNorth,
      l10n.regionCentral,
      l10n.regionSouth,
    ];

    final currentPlace = _places[_selectedRegionIndex];

    return PromoteSlideScaffold(
      title: l10n.promoteExploreTitle,
      description: l10n.promoteExploreDesc,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            TextField(
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                hintText: l10n.searchTrailsPlaces,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            HorizontalChipBar(
              items: regions,
              selectedIndex: _selectedRegionIndex,
              onSelect: (index) {
                setState(() {
                  _selectedRegionIndex = index;
                });
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Ảnh nền
                        Image.network(
                          currentPlace.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: colorScheme.surfaceContainerHigh,
                            child: Icon(
                              Icons.terrain,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              stops: const [0.4, 0.65, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Text(
                            currentPlace.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoteExplorePlace {
  final String name;
  final String imageUrl;

  const _PromoteExplorePlace({
    required this.name,
    required this.imageUrl,
  });
}