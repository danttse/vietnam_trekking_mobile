import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';

import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/home_journey_map.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/recent_place_card.dart';
import 'package:vietnam_trekking_mobile/core/widgets/sheet/select_province_sheet.dart';
import 'package:vietnam_trekking_mobile/features/profile/views/profile_screen.dart';

import '../viewmodel/home_view_model.dart';
import '../../profile/view_models/profile_viewmodel.dart';
import '../widgets/home_profile_button.dart';
import '../../explore/views/place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel.create();
    viewModel.addListener(_onActivityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileViewModel>().ensureLoaded();
    });
  }

  void _onActivityChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    viewModel.removeListener(_onActivityChanged);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<ProfileViewModel>();

    return SafeArea(
      child: Column(
        children: [
          if (viewModel.activityError != null)
            ListTile(
              title: Text(viewModel.activityError!),
              trailing: TextButton(
                onPressed: viewModel.loadActivity,
                child: const Text('Thử lại'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/img_app_logo_ver2.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HomeProfileButton(
                        name: user.profile.name,
                        avatarUrl: user.profile.avatarUrl,
                        rank: user.rankProfile?.rank,
                        isLoading: user.isLoading || user.isRankLoading,
                        onTap: () {
                          if (widget.onProfileTap != null) {
                            widget.onProfileTap!();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListenableBuilder(
                        listenable: viewModel,
                        builder: (context, _) => CardHomeStats(
                          icon: Icons.map,
                          iconColor: Colors.green,
                          value:
                              '${viewModel.visitedProvinces.length}/${viewModel.provinces.length}',
                          title: l10n.homeStatProvinces,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CardHomeStats(
                        icon: Icons.route,
                        iconColor: Colors.green,
                        value:
                            '${viewModel.totalDistanceKm.toStringAsFixed(1)} km',
                        title: l10n.homeStatDistance,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CardHomeStats(
                        icon: Icons.terrain,
                        iconColor: Colors.green,
                        value: '${viewModel.completedTrips}',
                        title: l10n.homeStatTrips,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  // Hiển thị loading spinner khi đang tải lần đầu và chưa có
                  // dữ liệu từ server (vẫn dùng static fallback)
                  if (viewModel.isLoadingProvinces) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        HomeJourneyMap(
                          provinces: viewModel.provinces,
                          maxHeight: double.infinity,
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.15),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    );
                  }
                  return HomeJourneyMap(
                    provinces: viewModel.provinces,
                    maxHeight: double.infinity,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                viewModel.recentPlaces.isNotEmpty
                    ? l10n.homeRecentCheckin
                    : l10n.recommendedForYou,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height:
                56 +
                MediaQuery.textScalerOf(context).scale(10) * 1.2 +
                (viewModel.recentPlaces.isNotEmpty
                    ? 2 + MediaQuery.textScalerOf(context).scale(9) * 1.2
                    : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) {
                      final places = viewModel.displayedPlaces;
                      if (places.isEmpty) {
                        if (viewModel.isLoadingPlaces) {
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return Center(
                          child: viewModel.placesError != null
                              ? TextButton(
                                  onPressed: viewModel.loadPlaces,
                                  child: Text(viewModel.placesError!),
                                )
                              : const Text('Chưa có địa điểm để khám phá'),
                        );
                      }
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        itemCount: places.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return RecentProvinceCard(
                            recentPlace: places[index],
                            onTap: places[index].placeId == null
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PlaceDetailScreen(
                                        placeId: places[index].placeId!,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 4),
                  child: FloatingActionButton.small(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        builder: (context) =>
                            SelectProvinceSheet(homeViewModel: viewModel),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
