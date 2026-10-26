import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/cards/home_journey_map.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/view_models/profile_viewmodel.dart';
import '../viewmodel/home_view_model.dart';
import 'home_profile_button.dart';

class HomePosterCard extends StatelessWidget {
  final HomeViewModel viewModel;
  final GlobalKey? captureKey;
  final double? width;
  final double? height;

  const HomePosterCard({
    super.key,
    required this.viewModel,
    this.captureKey,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profileVm = context.watch<ProfileViewModel?>();
    final userName = profileVm?.profile.name ?? 'Trekker';
    final userAvatar = profileVm?.profile.avatarUrl;
    final userRank = profileVm?.rankProfile?.rank;

    final drumColor = isDark
        ? const Color(0xFFD4AF37) 
        : const Color(0xFF8C6D37);
    final accentColor = isDark
      ? const Color(0xFF1BEA63)
      : const Color(0xFF2E5E43);

    final visitedCount = viewModel.visitedProvinces.length;
    final totalCount = viewModel.provinces.length;
    final distanceText = '${viewModel.totalDistanceKm.toStringAsFixed(1)} km';
    final tripsText = '${viewModel.completedTrips}';

    Widget posterContent = Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(maxWidth: 420),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07140B) : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.45 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      //copy homescreen
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: isDark ? 0.08 : 0.05,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.7, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.asset(
                        'assets/images/img_trong_dong.png',
                        fit: BoxFit.contain,
                        color: drumColor,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Opacity(
          //     opacity: 0.1,
          //     child: AspectRatio(
          //       aspectRatio: 1.0,
          //       child: Image.asset(
          //         'assets/images/img_vietnam_mountain.png',
          //         fit: BoxFit.contain,
          //         colorBlendMode: BlendMode.srcIn,
          //         errorBuilder: (_, __, ___) => const SizedBox(),
          //       ),
          //     ),
          //   )
          // ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/img_app_logo_ver2.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 38,
                          height: 38,
                          color: const Color(0xFF0F2618),
                          child: const Icon(Icons.terrain, color: Color(0xFF1BEA63), size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.appName ?? 'TrekViệt',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : colorScheme.onSurface,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'Hành trình của tôi',
                            style: TextStyle(
                              fontSize: 11,
                              color: (isDark ? Colors.white : colorScheme.onSurface).withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HomeProfileButton(
                        name: userName,
                        avatarUrl: userAvatar,
                        rank: userRank,
                        onTap: () {},
                      ),
                    ),

                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //   decoration: BoxDecoration(
                    //     color: isDark ? const Color(0xFF0F2618) : colorScheme.surfaceContainerHighest,
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(
                    //       color: accentColor.withValues(alpha: 0.3),
                    //       width: 1,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        icon: Icons.map,
                        value: '$visitedCount/$totalCount',
                        title: l10n?.homeStatProvinces ?? 'Tỉnh thành',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        icon: Icons.route,
                        value: distanceText,
                        title: l10n?.homeStatDistance ?? 'Quãng đường',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        icon: Icons.terrain,
                        value: tripsText,
                        title: l10n?.homeStatTrips ?? 'Chuyến đi',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 380,
                  child: Center(
                    child: HomeJourneyMap(
                      provinces: viewModel.provinces,
                      maxHeight: 380,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HÀNH TRÌNH KHÁM PHÁ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: (isDark ? Colors.white : colorScheme.onSurface).withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'VIỆT NAM',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),

                    Transform.rotate(
                      angle: -0.1,
                      child: Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.terrain,
                                color: accentColor,
                                size: 16,
                              ),
                              SizedBox(height: 1),
                              Text(
                                'TrekViệt',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                'BẢN QUYỀN',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 6,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (captureKey != null) {
      return RepaintBoundary(
        key: captureKey,
        child: posterContent,
      );
    }

    return posterContent;
  }

  Widget _buildStatCard({
    required bool isDark,
    required ColorScheme colorScheme,
    required IconData icon,
    required String value,
    required String title,
  }) {
    final accentColor = isDark
      ? const Color(0xFF1BEA63)
      : const Color(0xFF2E5E43);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2618) : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
