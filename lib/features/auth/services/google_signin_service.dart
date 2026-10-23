import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service để xử lý Google Sign-In flow
///
/// Sử dụng google_sign_in package để lấy Google ID Token,
/// sau đó gửi token này đến backend để verify và tạo session.
class GoogleSignInService {
  // Web Client ID cần thiết để lấy ID Token trên Android
  // Đây là Client ID Web, không phải Android Client ID
  static const String _webClientId =
      '820891588608-v1b063lrgcal4beea71ad9qdlsg5hf4c.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Quan trọng: serverClientId phải là WEB Client ID
    // để có thể lấy được ID Token
    serverClientId: _webClientId,
  );

  /// Bắt đầu Google Sign-In flow
  ///
  /// Returns: Google ID Token nếu thành công, null nếu user hủy
  /// Throws: Exception nếu có lỗi trong quá trình sign-in
  Future<String?> signIn() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[GoogleSignInService] Starting sign-in with serverClientId: $_webClientId',
        );
      }

      // Bước 1: Hiển thị Google Sign-In UI
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User đã hủy sign-in
        if (kDebugMode) {
          debugPrint('[GoogleSignInService] User cancelled sign-in');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Account selected');
      }

      // Bước 2: Lấy authentication details
      final GoogleSignInAuthentication auth = await account.authentication;

      if (kDebugMode) {
        debugPrint(
          '[GoogleSignInService] Got authentication, checking tokens...',
        );
        debugPrint(
          '[GoogleSignInService] Access Token exists: ${auth.accessToken != null}',
        );
        debugPrint(
          '[GoogleSignInService] ID Token exists: ${auth.idToken != null}',
        );
      }

      // Bước 3: Lấy ID Token
      final String? idToken = auth.idToken;

      if (idToken == null) {
        if (kDebugMode) {
          debugPrint('[GoogleSignInService] ERROR: idToken is null!');
          debugPrint(
            '[GoogleSignInService] This means serverClientId is not configured correctly',
          );
        }
        throw Exception(
          'Failed to get ID Token from Google. Please check serverClientId configuration.',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '[GoogleSignInService] Successfully got ID Token (length: ${idToken.length})',
        );
      }

      return idToken;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Error during sign-in: $e');
        debugPrint('[GoogleSignInService] Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }

  /// Đăng xuất khỏi Google account
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Signed out from Google');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Error during sign-out: $e');
      }
      rethrow;
    }
  }

  /// Kiểm tra xem user có đang đăng nhập Google không
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Disconnect khỏi Google (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Disconnected from Google');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignInService] Error during disconnect: $e');
      }
      rethrow;
    }
  }
}
