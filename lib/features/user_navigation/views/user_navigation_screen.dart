import 'package:flutter/material.dart';
import '../../../core/widgets/cards/bottom_navigation.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = UserNavigationViewModel();
    if (widget.initialIndex != 0) {
      _viewModel.setIndex(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tính năng đang được phát triển',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
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
              HomeScreen(
                onProfileTap: () => _viewModel.goToProfile(),
              ),
              _buildPlaceholder('Khám phá', Icons.explore_outlined),
              _buildPlaceholder('Cộng đồng', Icons.people_outline),
              _buildPlaceholder('Hành trình', Icons.route_outlined),
              ProfileScreen(
                onBackToHome: () => _viewModel.goToHome(),
              ),
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
