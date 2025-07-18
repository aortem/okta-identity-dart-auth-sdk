/// Represents the token response received from Okta's OAuth2 token endpoint.
///
/// Contains the authentication tokens and metadata returned after a successful
/// username/password authentication.
class AortemOktaTokenResponse {
  /// The access token used to authenticate API requests.
  final String accessToken;

  /// The ID token containing user information in JWT format (optional).
  final String? idToken;

  /// The refresh token used to obtain new access tokens (optional).
  final String? refreshToken;

  /// The lifetime in seconds of the access token.
  final int expiresIn;

  /// The type of token returned (typically 'Bearer').
  final String tokenType;

  /// Creates an instance of [AortemOktaTokenResponse] with the given token values.
  AortemOktaTokenResponse({
    required this.accessToken,
    this.idToken,
    this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  /// Creates an instance from a JSON map.
  factory AortemOktaTokenResponse.fromJson(Map<String, dynamic> json) {
    return AortemOktaTokenResponse(
      accessToken: json['access_token'],
      idToken: json['id_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      tokenType: json['token_type'],
    );
  }
}
