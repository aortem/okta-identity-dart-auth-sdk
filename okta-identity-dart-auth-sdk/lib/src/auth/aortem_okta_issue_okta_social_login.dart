import 'dart:async';
import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// A class to handle social login via Okta using a consumer pattern.
///
/// This class implements the OAuth 2.0 Token Exchange grant type to enable
/// federated authentication with identity providers such as Google, Facebook,
/// or other social providers supported by Okta.
///
/// The consumer pattern allows flexible configuration of the authentication
/// payload while ensuring required parameters are present.
class AortemOktaSocialLoginConsumer {
  /// The base domain URL of the Okta authorization server (e.g., 'https://your-org.okta.com')
  final String oktaDomain;

  /// The client ID of the OAuth application registered in Okta
  final String clientId;

  /// The redirect URI registered in the Okta application
  final String redirectUri;

  /// The HTTP client used to make requests (can be customized for testing)
  final http.Client httpClient;

  /// Creates an instance of [AortemOktaSocialLoginConsumer].
  ///
  /// Requires:
  /// - [oktaDomain]: The base URL of your Okta organization
  /// - [clientId]: The client ID of your Okta OAuth application
  /// - [redirectUri]: The redirect URI registered in your Okta application
  ///
  /// Optional:
  /// - [httpClient]: Custom HTTP client instance (defaults to a new [http.Client])
  AortemOktaSocialLoginConsumer({
    required this.oktaDomain,
    required this.clientId,
    required this.redirectUri,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Initiates the social sign-in process using the OAuth 2.0 Token Exchange grant.
  ///
  /// The [modifyPayload] callback allows customization of the authentication payload
  /// while ensuring required fields are present. The callback must provide:
  /// - 'provider': The identity provider name (e.g., 'google', 'facebook')
  /// - 'social_token': The token obtained from the social provider
  ///
  /// Example usage:
  /// ```dart
  /// final socialLogin = AortemOktaSocialLoginConsumer(
  ///   oktaDomain: 'https://your-org.okta.com',
  ///   clientId: 'your_client_id',
  ///   redirectUri: 'com.example.app:/callback',
  /// );
  ///
  /// final tokens = await socialLogin.signIn((payload) async {
  ///   payload['provider'] = 'google';
  ///   payload['social_token'] = googleAuthToken;
  ///   payload['scope'] = 'openid profile email offline_access';
  /// });
  /// ```
  ///
  /// Returns a [Map] containing the authentication tokens (access_token, id_token, etc.)
  /// on successful authentication.
  ///
  /// Throws [ArgumentError] if required fields ('provider' or 'social_token') are missing.
  /// Throws [Exception] if the authentication request fails.
  Future<Map<String, dynamic>> signIn(
      FutureOr<void> Function(Map<String, dynamic>) modifyPayload) async {
    // Base payload with required OAuth2 parameters for token exchange
    final Map<String, dynamic> body = {
      'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'openid profile email', // Default scope
    };

    // Allow the consumer to customize the payload
    await modifyPayload(body);

    // Validate required social authentication fields
    if (!body.containsKey('provider') || !body.containsKey('social_token')) {
      throw ArgumentError(
          'Missing required fields: provider and/or social_token');
    }

    final uri = Uri.parse('$oktaDomain/oauth2/v1/token');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final response = await httpClient.post(
      uri,
      headers: headers,
      body: body.map((key, value) => MapEntry(key, value.toString())),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to authenticate with social provider: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
