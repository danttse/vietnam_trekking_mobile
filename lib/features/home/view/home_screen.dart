import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/home_journey_map.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/recent_place_card.dart';
import 'package:vietnam_trekking_mobile/core/widgets/sheet/select_province_sheet.dart';
import 'package:vietnam_trekking_mobile/features/profile/views/profile_screen.dart';
import '../viewmodel/home_view_model.dart';

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
  final HomeViewModel viewModel = HomeViewModel();

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'TrekViệt',
                      style: TextStyle(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'PHÂN HẠNG',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tên người dùng',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            ),
                          ],
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
                          title: 'Tỉnh thành',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: CardHomeStats(
                        icon: Icons.route,
                        iconColor: Colors.green,
                        value: '384 km',
                        title: 'Quãng đường',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: CardHomeStats(
                        icon: Icons.terrain,
                        iconColor: Colors.green,
                        value: '12',
                        title: 'Chuyến đi',
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
                builder: (context, _) => HomeJourneyMap(
                  provinces: viewModel.provinces,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Check-In gần đây',
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