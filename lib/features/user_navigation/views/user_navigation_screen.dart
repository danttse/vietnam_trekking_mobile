import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/widgets/cards/bottom_navigation.dart';
<<<<<<< HEAD
import '../../auth/views/login_screen.dart';
=======
import '../../community/views/community_screen.dart';
>>>>>>> 0d0cdff74107768d2522b7d5e7c5e978bab6ca9c
import '../../home/view/home_screen.dart';
import '../../explore/views/explore_screen.dart';
// [TEST-ONLY] import màn hình detail tạm – xóa khi pull code dev frontend về
import '../../explore/views/test_explore_detail_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../community/views/community_screen.dart';
import '../../journey/views/journey_list_screen.dart';
import '../view_models/user_navigation_viewmodel.dart';

/// Màn hình điều phối chính phía người dùng (User Shell Navigation)
class UserNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const UserNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<UserNavigationScreen> createState() => _UserNavigationScreenState();
}

class _UserNavigationScreenState extends State<UserNavigationScreen> {
  late final UserNavigationViewModel _viewModel;
  StreamSubscription<AuthEvent>? _authSub;

  @override
  void initState() {
    super.initState();
    _viewModel = UserNavigationViewModel();
    if (widget.initialIndex != 0) {
      _viewModel.setIndex(widget.initialIndex);
    }

    // Lắng nghe authExpired (token refresh thất bại) và loggedOut (user đăng xuất)
    // → điều hướng về LoginScreen, xóa toàn bộ stack
    _authSub = AuthEventBus().stream.listen((event) {
      if (!mounted) return;
      if (event == AuthEvent.authExpired || event == AuthEvent.loggedOut) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    });
  }

  @override
  void dispose() {
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
              HomeScreen(
                onProfileTap: () => _viewModel.goToProfile(),
              ),
<<<<<<< HEAD
              // [TEST-ONLY] onPlaceTap mở TestExploreDetailScreen tạm thời
              // Xóa đoạn này khi pull code dev frontend về, thay bằng ExploreScreen() gốc
              ExploreScreen(
                onPlaceTap: (place) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TestExploreDetailScreen(place: place),
                    ),
                  );
                },
=======
              const ExploreScreen(),
              const CommunityScreen(),
              _buildPlaceholder(AppLocalizations.of(context)!.navJourney, Icons.route_outlined),
              ProfileScreen(
                onBackToHome: () => _viewModel.goToHome(),
>>>>>>> 0d0cdff74107768d2522b7d5e7c5e978bab6ca9c
              ),
              const CommunityScreen(),
              const JourneyListScreen(),
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
