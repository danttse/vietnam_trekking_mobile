import 'package:flutter/material.dart';

import '../../../core/services/offline_store.dart';
import '../../../core/services/token_storage.dart';
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

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<bool> _session = SessionGate.hasStoredSession(
    widget.tokenStorage,
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _session,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return snapshot.data == true
          ? const UserNavigationScreen()
          : const LoginScreen();
    },
  );
}
