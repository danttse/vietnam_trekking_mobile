import 'package:flutter/material.dart';
import '../../../app/theme/app_theme_viewmodel.dart';
import '../../../core/widgets/cards/bottom_navigation.dart';
import '../view_models/profile_viewmodel.dart';
import '../widgets/profile_widgets.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final ProfileViewModel _profileViewModel = ProfileViewModel();
  final AppThemeViewModel _themeViewModel = AppThemeViewModel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = _profileViewModel.profile;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cài Đặt',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: ProfileHeaderCard(
                  name: profile.name,
                  isPro: profile.isPro,
                  memberSince: 'Thành viên từ ${profile.memberSince}',
                  bio: profile.bio,
                  subTitle: profile.email,
                  avatarUrl: profile.avatarUrl,
                ),
              ),
              const SizedBox(height: 20),
              //Nhom 1 tai khoan
              ProfileSettingGroupItem(
                title: 'TÀI KHOẢN',
                items: [
                  ProfileSettingItem(
                    mainTitle: 'Đổi mật khẩu',
                    icon: Icons.lock_outline,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Đổi mật khẩu đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  ProfileSettingItem(
                    mainTitle: 'Đổi ngôn ngữ',
                    icon: Icons.language,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Đổi ngôn ngữ đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  ProfileSettingItem(
                    mainTitle: 'Đổi ảnh đại diện',
                    icon: Icons.photo_camera_outlined,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Đổi ảnh đại diện đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //Nhom 2 Giao dien
              ListenableBuilder(
                listenable: _themeViewModel,
                builder: (context, _) => ProfileSettingGroupItem(
                  title: 'GIAO DIỆN',
                  items: [
                    ProfileSettingItem(
                      mainTitle: 'Chế độ tối',
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch.adaptive(
                        value: _themeViewModel.isDarkMode,
                        activeTrackColor: colorScheme.primary,
                        onChanged: (value) => _themeViewModel.setDarkMode(value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Nhom 3 Dong gop
              ProfileSettingGroupItem(
                title: 'ĐÓNG GÓP',
                items: [
                  ProfileSettingItem(
                    mainTitle: 'Đề xuất địa điểm mới',
                    icon: Icons.place_outlined,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Đề xuất địa điểm đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  ProfileSettingItem(
                    mainTitle: 'Hỗ trợ & Phản hồi',
                    icon: Icons.help_outline,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Hỗ trợ & Phản hồi đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Group 4: KHÁC
              ProfileSettingGroupItem(
                title: 'KHÁC',
                items: [
                  ProfileSettingItem(
                    mainTitle: 'Điều khoản sử dụng',
                    icon: Icons.description_outlined,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Điều khoản sử dụng đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  ProfileSettingItem(
                    mainTitle: 'Chính sách quyền riêng tư',
                    icon: Icons.privacy_tip_outlined,
                    onTapAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Chính sách quyền riêng tư đang phát triển'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BtnOutlineStyle(
                text: 'Đăng xuất',
                icon: const Icon(Icons.exit_to_app),
                onPressed: ()=>{},
              ),
              const SizedBox(height:8)
            ],
          ),
        ),
      ),
    );
  }
}
