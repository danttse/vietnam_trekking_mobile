import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── Abstract interface ───────────────────────────────────────────────────────

abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

// ─── Exception ────────────────────────────────────────────────────────────────

class StorageException implements Exception {
  final String errorCode;
  final String message;

  const StorageException({required this.errorCode, required this.message});

  @override
  String toString() => 'StorageException[$errorCode]: $message';
}

// ─── Implementation ───────────────────────────────────────────────────────────

class SecureTokenStorage implements TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Returns the stored access token, or [null] on PlatformException.
  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[SecureTokenStorage] Failed to read access token: ${e.message}',
        );
      }
      return null;
    }
  }

  /// Returns the stored refresh token, or [null] on PlatformException.
  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[SecureTokenStorage] Failed to read refresh token: ${e.message}',
        );
      }
      return null;
    }
  }

  /// Atomically writes [accessToken] then [refreshToken].
  ///
  /// If either write fails, both keys are deleted before throwing
  /// [StorageException] with errorCode `'STORAGE_WRITE_FAILED'`.
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    } catch (e) {
      // Access token write failed — clean up and throw.
      await _safeDeleteBoth();
      throw StorageException(
        errorCode: 'STORAGE_WRITE_FAILED',
        message: 'Failed to write access token: $e',
      );
    }

    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      // Refresh token write failed — roll back by deleting both keys.
      await _safeDeleteBoth();
      throw StorageException(
        errorCode: 'STORAGE_WRITE_FAILED',
        message: 'Failed to write refresh token: $e',
      );
    }
  }

  /// Deletes both token keys concurrently.
  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Attempts to delete both keys, swallowing any errors.
  Future<void> _safeDeleteBoth() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
    } catch (_) {
      // Best-effort cleanup — ignore secondary failures.
    }
  }
}
