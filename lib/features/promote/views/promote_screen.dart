import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/features/auth/views/login_screen.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_community_slide.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_explore_slide.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_first_slide.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_gps_slide.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_offline_slide.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_stats_slide.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteScreen extends StatefulWidget {
  const PromoteScreen({super.key});

  @override
  State<PromoteScreen> createState() => _PromoteScreenState();
}

class _PromoteScreenState extends State<PromoteScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = 6;
    if (_currentPage >= pageCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentPage = 0);
        _pageController.jumpToPage(0);
      });
    }
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body:SafeArea(bottom: true,top:false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: const [
              PromoteFirstSlide(),
              PromoteExploreSlide(),
              PromoteGpsSlide(),
              PromoteOfflineSlide(),
              PromoteStatsSlide(),
              PromoteCommunitySlide(),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    l10n.promoteSkip,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pageCount, (index) {
                      final active = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width:10),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_currentPage < 5) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _navigateToLogin();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    l10n.promoteNext,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  icon: Icon(
                    Icons.navigate_next,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      ),
    );
  }
}