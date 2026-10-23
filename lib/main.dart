import 'package:flutter/material.dart';

import 'dart:async';

import 'core/services/trekking_catalog_service.dart';
import 'core/services/location_service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vietnam_trekking_mobile/app/language/app_language_viewmodel.dart';
import '../../../l10n/app_localizations.dart';
import 'features/auth/views/session_gate.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_viewmodel.dart';
import 'features/profile/view_models/profile_viewmodel.dart';

void main() {
  runApp(const VietnamTrekkingApp());
}

class VietnamTrekkingApp extends StatefulWidget {
  const VietnamTrekkingApp({super.key});

  @override
  State<VietnamTrekkingApp> createState() => _VietnamTrekkingAppState();
}

class _VietnamTrekkingAppState extends State<VietnamTrekkingApp>
    with WidgetsBindingObserver {
  Timer? _syncTimer;
  late final TrekkingCatalogService _offlineApi;
  Future<void> _syncOffline() async {
    try {
      await _offlineApi.syncPending();
    } catch (_) {
      /* Retain durable outbox for the next attempt. */
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncTimer?.cancel();
    _syncTimer = null;
    if (state == AppLifecycleState.resumed) {
      _startSyncTimer();
      unawaited(_syncOffline());
    }
  }

  void _startSyncTimer() {
    _syncTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_syncOffline()),
    );
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  final AppThemeViewModel _themeViewModel = AppThemeViewModel();
  final AppLanguageViewModel _appLanguageViewModel = AppLanguageViewModel();

  @override
  void initState() {
    super.initState();
    _offlineApi = TrekkingCatalogService();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(LocationService.instance.initialize(requestPermission: true));
      }
    });
    _startSyncTimer();
    unawaited(_syncOffline());
    _themeViewModel.addListener(_onPreferencesChanged);
    _appLanguageViewModel.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _themeViewModel.removeListener(_onPreferencesChanged);
    _appLanguageViewModel.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeViewModel.themeMode,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _appLanguageViewModel.currentLocale,
        home: const SessionGate(),
      ),
    );
  }
}
