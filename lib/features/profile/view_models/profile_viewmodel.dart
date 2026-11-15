import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/user_api_service.dart';
import '../../../core/models/rank_model.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/gamification_event_bus.dart';
import '../../../core/network/api_error_handler.dart';
import '../data/models/profile_model.dart';

class RankUpdate {
  final UserRankProfile previous;
  final UserRankProfile current;
  const RankUpdate(this.previous, this.current);
  num get xpEarned => current.totalXp - previous.totalXp;
  bool get promoted => current.rank.level > previous.rank.level;
}

class ProfileViewModel extends ChangeNotifier {
  final UserApiService _api;
  late final StreamSubscription<AuthEvent> _authSubscription;
  late final StreamSubscription<void> _activitySubscription;
  final _rankUpdates = StreamController<RankUpdate>.broadcast();
  Stream<RankUpdate> get rankUpdates => _rankUpdates.stream;
  UserRankProfile? _observedRank;
  Timer? _rankTimer;
  final List<Timer> _activityTimers = [];
  bool _monitoring = false;
  bool _disposed = false;
  int _generation = 0;
  bool isLoading = false;
  String? error;
  UserRankProfile? rankProfile;
  RankProgress? rankProgress;
  List<RankDefinition> ranks = [];
  bool isRankLoading = false;
  bool isRankCatalogLoading = false;
  String? rankError;
  String? rankCatalogError;
  int _rankGeneration = 0;
  int _catalogGeneration = 0;
  int _badgeGeneration = 0;
  static const empty = UserProfileModel(
    id: '',
    name: '',
    isPro: false,
    memberSince: '',
    bio: '',
    visitedProvinces: 0,
    totalDistanceKm: 0,
    completedTrips: 0,
    totalDays: 0,
    achievements: [],
  );
  UserProfileModel _profile = empty;
  UserProfileModel get profile => _profile;

  ProfileViewModel({UserApiService? api}) : _api = api ?? UserApiService() {
    _activitySubscription = GamificationEventBus().stream.listen((_) {
      if (!_monitoring) return;
      for (final timer in _activityTimers) {
        timer.cancel();
      }
      _activityTimers.clear();
      // Event consumption and badge evaluation may finish after the HTTP response.
      for (final seconds in [1, 3, 6]) {
        _activityTimers.add(Timer(Duration(seconds: seconds), refreshRank));
      }
    });
    _authSubscription = AuthEventBus().stream.listen((_) {
      stopRankUpdates();
      _observedRank = null;
      _generation++;
      _profile = empty;
      _rankGeneration++;
      _catalogGeneration++;
      _badgeGeneration++;
      rankProfile = null;
      rankProgress = null;
      ranks = [];
      rankError = null;
      rankCatalogError = null;
      isRankLoading = false;
      isRankCatalogLoading = false;
      error = null;
      isLoading = false;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> ensureLoaded() async {
    if (!isLoading && _profile.id.isEmpty) await load();
  }

  Future<void> load() async {
    final generation = ++_generation;
    _rankGeneration++;
    isRankLoading = false;
    isLoading = true;
    error = null;
    notifyListeners();
    bool stale() => _disposed || generation != _generation;
    try {
      final user = await _api.getProfile();
      if (stale()) return;
      final joined = DateTime.tryParse(user['createdAt']?.toString() ?? '');
      if (_profile.id != user['userId'].toString()) {
        _observedRank = null;
        rankProfile = null;
        rankProgress = null;
      }
      _profile = UserProfileModel(
        id: user['userId'].toString(),
        name: user['displayName'] as String? ?? '',
        isPro: false,
        memberSince: joined == null ? '' : '${joined.month}/${joined.year}',
        bio: user['bio'] as String? ?? '',
        email: user['email'] as String?,
        avatarUrl: user['avatarUrl'] as String?,
        visitedProvinces: 0,
        totalDistanceKm: 0,
        completedTrips: 0,
        totalDays: 0,
        achievements: [],
      );
      notifyListeners();
      // Load independent panels separately so one service outage does not hide the profile.
      await Future.wait([
        loadRank(),
        _loadPanel(() async {
          final stats = await _api.getStatistics();
          if (stale()) return;
          _profile = _profile.copyWith(
            totalDistanceKm:
                ((stats['totalDistanceMeters'] as num? ?? 0) / 1000).round(),
            completedTrips: (stats['totalJourneys'] as num? ?? 0).toInt(),
            totalDays: ((stats['totalDurationSeconds'] as num? ?? 0) / 86400)
                .floor(),
          );
        }, stale),
        _loadPanel(() async {
          final visits = await _api.getProvinceVisits();
          if (stale()) return;
          final summary = visits['summary'] as Map? ?? {};
          _profile = _profile.copyWith(
            visitedProvinces: (summary['visitedCount'] as num? ?? 0).toInt(),
            totalProvinces: (summary['totalProvinces'] as num? ?? 34).toInt(),
          );
        }, stale),
        loadBadges(),
      ]);
    } catch (e) {
      if (!stale()) error = ApiErrorHandler.handle(e);
    } finally {
      if (!stale()) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadBadges() async {
    final generation = _generation;
    final badgeGeneration = ++_badgeGeneration;
    bool stale() =>
        _disposed ||
        generation != _generation ||
        badgeGeneration != _badgeGeneration;
    await _loadPanel(() async {
      final results = await Future.wait([
        _api.getBadges(),
        _api.getEarnedBadges(),
      ]);
      if (stale()) return;
      final earned = <String, Map<String, dynamic>>{};
      final catalog = <String, Map<String, dynamic>>{};
      for (final badge in results[0]) {
        final id = (badge['badgeId'] ?? badge['_id'] ?? badge['id']).toString();
        catalog[id] = badge;
      }
      for (final item in results[1]) {
        final badge = item['badgeId'];
        if (badge == null) continue;
        final id = badge is Map
            ? (badge['badgeId'] ?? badge['_id'] ?? badge['id']).toString()
            : badge.toString();
        earned[id] = item;
        if (badge is Map) {
          catalog.putIfAbsent(id, () => Map<String, dynamic>.from(badge));
        }
      }
      _profile = _profile.copyWith(
        achievements: catalog.entries.map((entry) {
          final badge = entry.value;
          final award = earned[entry.key];
          final earnedAt = DateTime.tryParse(
            award?['earnedAt']?.toString() ?? '',
          );
          final condition = badge['condition'] as Map? ?? {};
          final target = (condition['value'] as num? ?? 1).ceil();
          final unit = switch (condition['type']) {
            'DISTANCE_TOTAL' => condition['unit'] == 'METERS' ? 'm' : 'km',
            'ALTITUDE_REACHED' || 'ELEVATION_TOTAL' => 'm',
            'PROVINCE_COUNT' || 'PROVINCE_VISITED_COUNT' => 'Tỉnh thành',
            'JOURNEY_COUNT' ||
            'JOURNEY_COMPLETED_COUNT' ||
            'FIRST_JOURNEY' => 'Hành trình',
            'PLACE_VISITED_COUNT' || 'SPECIFIC_PLACE' => 'Địa điểm',
            'CONTRIBUTION_APPROVED' => 'Đóng góp',
            _ => 'Check-in',
          };
          return AchievementModel(
            id: entry.key,
            title: badge['name'] as String? ?? '',
            description: badge['description'] as String? ?? '',
            icon: Icons.military_tech_outlined,
            isUnlocked: award != null,
            achievedDate: earnedAt == null
                ? null
                : '${earnedAt.day}/${earnedAt.month}/${earnedAt.year}',
            currentProgress: award == null ? 0 : target,
            totalProgress: target,
            progressUnit: unit,
          );
        }).toList(),
      );
    }, stale);
  }

  void startRankUpdates() {
    if (_disposed) return;
    stopRankUpdates();
    _monitoring = true;
    _rankTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshRank(),
    );
    refreshRank();
  }

  void stopRankUpdates() {
    _monitoring = false;
    _rankTimer?.cancel();
    for (final timer in _activityTimers) {
      timer.cancel();
    }
    _activityTimers.clear();
  }

  Future<void> refreshRank() async {
    if (_disposed || !_monitoring || isLoading || isRankLoading) return;
    if (_profile.id.isEmpty) {
      await ensureLoaded();
    } else {
      await Future.wait([loadRank(silent: true), loadBadges()]);
    }
  }

  Future<void> loadRank({bool silent = false}) async {
    if (_disposed || _profile.id.isEmpty) return;
    final generation = _generation;
    final rankGeneration = ++_rankGeneration;
    bool stale() =>
        _disposed ||
        generation != _generation ||
        rankGeneration != _rankGeneration;
    isRankLoading = true;
    rankError = null;
    if (!silent) rankProgress = null;
    notifyListeners();
    // Load each panel independently: a progress failure must not hide the user's rank/XP.
    await Future.wait([
      () async {
        try {
          final data = await _api.getRankProfile();
          if (!stale()) {
            final previous = _observedRank;
            rankProfile = data;
            _observedRank = data;
            if (previous != null) {
              final update = RankUpdate(previous, data);
              if (update.promoted) {
                _rankUpdates.add(update);
              }
            }
          }
        } catch (e) {
          if (!stale()) rankError = ApiErrorHandler.handle(e);
        }
        if (!stale()) notifyListeners();
      }(),
      () async {
        try {
          final data = await _api.getRankProgress();
          if (!stale()) rankProgress = data;
        } catch (e) {
          if (!stale()) rankError = ApiErrorHandler.handle(e);
        }
        if (!stale()) notifyListeners();
      }(),
    ]);
    if (!stale()) {
      if (rankProfile?.rank.code != rankProgress?.currentRank.code) {
        rankProgress = null;
      }
      isRankLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRankCatalog() async {
    final generation = ++_catalogGeneration;
    isRankCatalogLoading = true;
    rankCatalogError = null;
    notifyListeners();
    try {
      final data = await _api.getRanks();
      if (!_disposed && generation == _catalogGeneration) ranks = data;
    } catch (e) {
      if (!_disposed && generation == _catalogGeneration) {
        rankCatalogError = ApiErrorHandler.handle(e);
      }
    } finally {
      if (!_disposed && generation == _catalogGeneration) {
        isRankCatalogLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadPanel(
    Future<void> Function() load,
    bool Function() stale,
  ) async {
    try {
      await load();
    } catch (e) {
      if (!stale()) error = ApiErrorHandler.handle(e);
    }
    if (!stale()) notifyListeners();
  }

  void updateProfile(UserProfileModel newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stopRankUpdates();
    _activitySubscription.cancel();
    _rankUpdates.close();
    _authSubscription.cancel();
    super.dispose();
  }
}
