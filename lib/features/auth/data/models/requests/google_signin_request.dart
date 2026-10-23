/// Request model for Google Sign-In
/// 
/// Contains the Google ID Token that needs to be verified by the backend.
class GoogleSignInRequest {
  final String idToken;

  const GoogleSignInRequest({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
      };
}
