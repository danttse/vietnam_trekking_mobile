import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        const AssetImage('assets/images/vietnam_landscape.webp'),
        context,
      );
      precacheImage(
        const AssetImage('assets/images/img_app_logo_ver1.png'),
        context,
      );
      precacheImage(
        const NetworkImage(
          'https://vcdn1-dulich.vnecdn.net/2023/09/26/thaonguyen1-9546-1695723031.jpg?w=0&h=0&q=100&dpr=2&fit=crop&s=hPttIphPb7dr9bd_O6FZvg',
        ),
        context,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markAsSeenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_promote', true);
    
    if (!mounted) return;
    
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
                  onPressed: _markAsSeenAndNavigate,
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
                        curve: Curves.fastOutSlowIn,
                      );
                    } else {
                      _markAsSeenAndNavigate();
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