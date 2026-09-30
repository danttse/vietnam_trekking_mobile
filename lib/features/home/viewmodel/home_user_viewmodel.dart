import 'package:flutter/foundation.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../auth/data/models/responses/user_dto.dart';
import '../../auth/repository/auth_repository_impl.dart';

/// Lightweight ViewModel that fetches the current user's display info
/// for the Home screen header.
class HomeUserViewModel extends ChangeNotifier {
  late final AuthRepositoryImpl _repository;

  UserDto? _user;
  bool _isLoading = false;

  UserDto? get user => _user;
  bool get isLoading => _isLoading;

  String get displayName => _user?.displayName ?? '';
  String get role => _user?.role ?? '';

  HomeUserViewModel() {
    final tokenStorage = const SecureTokenStorage();
    final eventBus = AuthEventBus();
    final dio = DioClient.createDio(tokenStorage: tokenStorage, eventBus: eventBus);
    _repository = AuthRepositoryImpl(dio: dio, tokenStorage: tokenStorage);
    _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _repository.getMe();
    } catch (e) {
      if (kDebugMode) debugPrint('[HomeUserViewModel] $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
