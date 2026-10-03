import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/home_journey_map.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/recent_place_card.dart';
import 'package:vietnam_trekking_mobile/core/widgets/sheet/select_province_sheet.dart';
import 'package:vietnam_trekking_mobile/features/profile/views/profile_screen.dart';
import '../viewmodel/home_view_model.dart';
import '../viewmodel/home_user_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel viewModel;
  final HomeUserViewModel _userViewModel = HomeUserViewModel();

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel.create();
  }

  @override
  void dispose() {
    viewModel.dispose();
    _userViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
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
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
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
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ListenableBuilder(
                          listenable: _userViewModel,
                          builder: (context, _) {
                            final user = _userViewModel.user;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.homeRankLabel,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.displayName ?? '...',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        value: '384 km',
                        title: l10n.homeStatDistance,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CardHomeStats(
                        icon: Icons.terrain,
                        iconColor: Colors.green,
                        value: '12',
                        title: l10n.homeStatTrips,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                        HomeJourneyMap(provinces: viewModel.provinces),
                        Container(
                          color: Colors.black.withValues(alpha: 0.15),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    );
                  }
                  return HomeJourneyMap(provinces: viewModel.provinces);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.homeRecentCheckin,
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
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) {
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        itemCount: viewModel.recentPlaces.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return RecentProvinceCard(
                            recentPlace: viewModel.recentPlaces[index],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: FloatingActionButton.small(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        builder: (context) => SelectProvinceSheet(
                          homeViewModel: viewModel,
                        ),
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