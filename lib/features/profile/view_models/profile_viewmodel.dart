import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../auth/data/exceptions/auth_exception.dart';
import '../../auth/data/models/responses/user_dto.dart';
import '../../auth/repository/auth_repository_impl.dart';
import '../data/models/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  late final AuthRepositoryImpl _repository;

  // ── State ──────────────────────────────────────────────────────────────────

  UserDto? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Hardcoded stat/achievement data until a stats API exists
  static const List<AchievementModel> _defaultAchievements = [
    AchievementModel(
      id: 'ach_1',
      title: 'Nhà thám hiểm',
      description: 'Đã trekking qua trên 5 tỉnh thành khác nhau.',
      icon: Icons.explore_outlined,
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'ach_2',
      title: 'Chinh phục đỉnh cao',
      description: 'Đã leo thành công đỉnh Fansipan cao 3,143m.',
      icon: Icons.landscape_outlined,
      isUnlocked: true,
    ),
    AchievementModel(
      id: 'ach_3',
      title: 'Dấu chân miền Nam',
      description: 'Đã chinh phục hết các tỉnh thành Nam Bộ.',
      icon: Icons.directions_walk,
      isUnlocked: false,
    ),
  ];

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserDto? get user => _user;

  /// Returns a [UserProfileModel] merging live API user data with local stats.
  UserProfileModel get profile {
    final u = _user;
    return UserProfileModel(
      id: u?.userId ?? '',
      name: u?.displayName ?? '...',
      isPro: false,
      memberSince: _formatMemberSince(u?.emailVerifiedAt),
      bio: u?.bio ?? 'Yêu thích khám phá Việt Nam',
      email: u?.email,
      avatarUrl: u?.avatarUrl,
      visitedProvinces: 0,
      totalDistanceKm: 0,
      completedTrips: 0,
      totalDays: 0,
      achievements: _defaultAchievements,
    );
  }

  // ── Constructor ────────────────────────────────────────────────────────────

  ProfileViewModel() {
    final tokenStorage = const SecureTokenStorage();
    final eventBus = AuthEventBus();
    final dio = DioClient.createDio(tokenStorage: tokenStorage, eventBus: eventBus);
    _repository = AuthRepositoryImpl(dio: dio, tokenStorage: tokenStorage);
    loadUser();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> loadUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.getMe();
      _isLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      if (kDebugMode) debugPrint('[ProfileViewModel] AuthException: ${e.message}');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải thông tin người dùng';
      if (kDebugMode) debugPrint('[ProfileViewModel] Error: $e');
      notifyListeners();
    }
  }

  /// Refresh lại user data từ API — alias cho [loadUser].
  Future<void> refresh() => loadUser();

  /// Cập nhật profile local
  void updateProfile(UserProfileModel newProfile) {
    if (_user != null) {
      _user = UserDto(
        userId: _user!.userId,
        displayName: newProfile.name,
        email: _user!.email,
        role: _user!.role,
        status: _user!.status,
        bio: newProfile.bio,
        avatarUrl: newProfile.avatarUrl,
        emailVerifiedAt: _user!.emailVerifiedAt,
      );
    }
    notifyListeners();
  }

  /// Cập nhật user local từ kết quả trả về của API (avatar/bio update)
  /// mà không cần gọi lại GET /users/me.
  void updateUserLocal(UserDto updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatMemberSince(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
        'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
        'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
      ];
      return '${months[dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
