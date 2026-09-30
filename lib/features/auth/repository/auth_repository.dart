import '../data/models/requests/login_request.dart';
import '../data/models/requests/register_request.dart';
import '../data/models/requests/reset_password_request.dart';
import '../data/models/requests/verify_otp_request.dart';
import '../data/models/responses/auth_response.dart';
import '../data/models/responses/otp_sent_response.dart';
import '../data/models/responses/reset_token_response.dart';
import '../data/models/responses/user_dto.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<OtpSentResponse> register(RegisterRequest request);
  Future<AuthResponse> verifyEmail(VerifyOtpRequest request);
  Future<OtpSentResponse> resendVerificationOtp(String email);
  Future<OtpSentResponse> forgotPassword(String email);
  Future<ResetTokenResponse> verifyResetOtp(VerifyOtpRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
  Future<void> logout({String? refreshToken});
  Future<UserDto> getMe();
  Future<UserDto> updateBio(String bio);
  Future<UserDto> uploadAvatar(String filePath);
}
