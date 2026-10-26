import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/offline_store.dart';
import '../../../core/services/token_storage.dart';
import '../../promote/views/promote_screen.dart';
import '../../user_navigation/views/user_navigation_screen.dart';
import 'login_screen.dart';

/// Restores an existing device session without requiring a network request.
/// Backend requests still authenticate/refresh through TokenInterceptor.
class SessionGate extends StatefulWidget {
  final TokenStorage tokenStorage;
  const SessionGate({
    super.key,
    this.tokenStorage = const SecureTokenStorage(),
  });

  static Future<bool> hasStoredSession(TokenStorage storage) async {
    final owner = OfflineStore.ownerFromToken(await storage.getAccessToken());
    final refresh = await storage.getRefreshToken();
    return owner != null &&
        owner.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  /// Check if user has seen the promote screen
  static Future<bool> hasSeenPromote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_promote') ?? false;
  }

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<bool> _session = SessionGate.hasStoredSession(
    widget.tokenStorage,
  );
  late final Future<bool> _hasSeenPromote = SessionGate.hasSeenPromote();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<bool>>(
    future: Future.wait([_session, _hasSeenPromote]),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final hasSession = snapshot.data?[0] ?? false;
      final hasSeenPromote = snapshot.data?[1] ?? false;

      // If already logged in, go to main app
      if (hasSession) {
        return const UserNavigationScreen();
      }

      // If not logged in and hasn't seen promote, show promote screen
      if (!hasSeenPromote) {
        return const PromoteScreen();
      }

      // Otherwise show login
      return const LoginScreen();
    },
  );
}
