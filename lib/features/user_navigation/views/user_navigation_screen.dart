import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/cards/bottom_navigation.dart';
import '../../auth/views/login_screen.dart';
import '../../home/view/home_screen.dart';
import '../../profile/views/profile_screen.dart';
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

  Widget _buildPlaceholder(String title, IconData icon) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.featureInDevelopment,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
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
              _buildPlaceholder(AppLocalizations.of(context)!.navExplore, Icons.explore_outlined),
              _buildPlaceholder(AppLocalizations.of(context)!.navCommunity, Icons.people_outline),
              _buildPlaceholder(AppLocalizations.of(context)!.navJourney, Icons.route_outlined),
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
