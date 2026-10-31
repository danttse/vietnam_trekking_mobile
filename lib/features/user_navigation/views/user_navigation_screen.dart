import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/view_models/profile_viewmodel.dart';
import '../../profile/widgets/rank_promotion_dialog.dart';

import '../../../core/services/auth_event_bus.dart';
import '../../../core/widgets/dialogs/session_expired_dialog.dart';
import '../../../core/widgets/cards/bottom_navigation.dart';
import '../../auth/views/login_screen.dart';
import '../../community/views/community_screen.dart';
import '../../home/view/home_screen.dart';
import '../../explore/views/explore_screen.dart';
import '../../explore/views/place_detail_screen.dart';
import '../../journey/views/journey_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../view_models/user_navigation_viewmodel.dart';
import '../../route/view/route_detail_screen.dart';
import '../../../core/services/trekking_catalog_service.dart';

/// Màn hình điều phối chính phía người dùng (User Shell Navigation)
class UserNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const UserNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<UserNavigationScreen> createState() => _UserNavigationScreenState();
}

class _UserNavigationScreenState extends State<UserNavigationScreen>
    with WidgetsBindingObserver {
  late final UserNavigationViewModel _viewModel;
  StreamSubscription<AuthEvent>? _authSub;
  StreamSubscription<RankUpdate>? _rankSub;
  ProfileViewModel? _profile;
  bool _sessionDialogOpen = false;
  bool _navigatingToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _profile = context.read<ProfileViewModel>();
      _rankSub = _profile!.rankUpdates.listen(_showRankUpdate);
      _profile!.startRankUpdates();
    });
    _viewModel = UserNavigationViewModel();
    if (widget.initialIndex != 0) {
      _viewModel.setIndex(widget.initialIndex);
    }

    // Lắng nghe authExpired (token refresh thất bại) và loggedOut (user đăng xuất)
    // → điều hướng về LoginScreen, xóa toàn bộ stack
    _authSub = AuthEventBus().stream.listen((event) {
      if (!mounted) return;

      if (event == AuthEvent.authExpired) {
        // Show friendly dialog when session expires
        _showSessionExpiredDialog();
      } else if (event == AuthEvent.loggedOut) {
        // Direct navigation for manual logout
        _goToLogin();
      }
    });
  }

  Future<void> _showRankUpdate(RankUpdate update) async {
    if (!mounted ||
        !update.promoted ||
        _sessionDialogOpen ||
        _navigatingToLogin) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => RankPromotionDialog(profile: update.current),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _profile?.startRankUpdates();
    } else {
      _profile?.stopRankUpdates();
    }
  }

  void _goToLogin() {
    if (!mounted || _navigatingToLogin) return;
    _navigatingToLogin = true;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _showSessionExpiredDialog() async {
    if (_sessionDialogOpen || _navigatingToLogin) return;
    _sessionDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SessionExpiredDialog(onSignIn: _goToLogin),
      );
    } finally {
      _sessionDialogOpen = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rankSub?.cancel();
    _profile?.stopRankUpdates();
    _authSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final currentIndex = _viewModel.currentIndex;

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: [
              HomeScreen(onProfileTap: () => _viewModel.goToProfile()),
              TickerMode(
                enabled: currentIndex == 1,
                child: ExploreScreen(
                  onPlaceTap: (place) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailScreen(placeId: place.id),
                    ),
                  ),
                  onTrailTap: (trail) async {
                    try {
                      final route = await TrekkingCatalogService().getRoute(
                        trail.id,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RouteDetailScreen(route: route),
                        ),
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Không thể tải cung đường. Vui lòng thử lại.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const CommunityScreen(),
              const JourneyScreen(),
              ProfileScreen(onBackToHome: () => _viewModel.goToHome()),
            ],
          ),
          bottomNavigationBar: HomeBottomNavigation(
            currentIndex: currentIndex,
            onTap: (index) => _viewModel.setIndex(index),
          ),
        );
      },
    );
  }
}
