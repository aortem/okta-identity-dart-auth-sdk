import 'dart:async';

import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// A callback type for modifying logout payload parameters.
///
/// Used to customize the logout request parameters before they are sent to Okta.
typedef LogoutPayloadModifier = FutureOr<void> Function(Map<String, String>);

/// A class to handle OpenID Connect logout operations with Okta using a consumer pattern.
///
/// This class implements the OIDC end-session endpoint to properly log users out
/// of both the application and Okta session. It supports the consumer pattern for
/// flexible payload configuration.
///
/// The logout flow follows OpenID Connect RP-Initiated Logout specifications.
class AortemOktaOidcLogoutConsumer {
  /// The base domain URL of the Okta authorization server
  /// (e.g., 'https://your-org.okta.com')
  final String oktaDomain;

  /// The client ID of the OAuth application registered in Okta
  final String clientId;

  /// The URI where the user should be redirected after logout
  final String postLogoutRedirectUri;

  /// The HTTP client used to make requests (can be customized for testing)
  final http.Client httpClient;

  /// Creates an instance of [AortemOktaOidcLogoutConsumer].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base URL of your Okta organization
  /// - [clientId]: The client ID of your Okta OAuth application
  /// - [postLogoutRedirectUri]: The redirect URI after logout completes
  ///
  /// Optional parameter:
  /// - [httpClient]: Custom HTTP client instance (defaults to a new [http.Client])
  AortemOktaOidcLogoutConsumer({
    required this.oktaDomain,
    required this.clientId,
    required this.postLogoutRedirectUri,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Initiates the OIDC logout flow.
  ///
  /// The [modify] callback allows customization of the logout parameters while
  /// ensuring required fields are present. The base payload includes:
  /// - client_id: The Okta application client ID
  /// - post_logout_redirect_uri: The redirect URI after logout
  ///
  /// Example usage:
  /// ```dart
  /// final logoutConsumer = AortemOktaOidcLogoutConsumer(
  ///   oktaDomain: 'https://your-org.okta.com',
  ///   clientId: 'your_client_id',
  ///   postLogoutRedirectUri: 'com.example.app:/postlogout',
  /// );
  ///
  /// final logoutUrl = await logoutConsumer.logout((payload) async {
  ///   // Optional: Add id_token_hint if available
  ///   payload['id_token_hint'] = storedIdToken;
  ///   // Optional: Change the redirect URI dynamically
  ///   payload['post_logout_redirect_uri'] = 'com.example.app:/customlogout';
  /// });
  /// ```
  ///
  /// Returns a [Uri] that can be used to redirect the user to complete logout.
  ///
  /// Throws [ArgumentError] if required parameters are missing or empty.
  /// Throws [Exception] if the logout request fails.
  Future<Uri> logout({required LogoutPayloadModifier modify}) async {
    // Base payload with required OIDC logout parameters
    final payload = <String, String>{
      'client_id': clientId,
      'post_logout_redirect_uri': postLogoutRedirectUri,
    };

    // Allow consumer to modify the payload
    await modify(payload);

    // Validate required parameters
    _validatePayload(payload);

    // Construct the logout URL with query parameters
    final logoutUrl = Uri.parse(
      '$oktaDomain/oauth2/v1/logout',
    ).replace(queryParameters: payload);

    // Make the logout request (returns 302 redirect by default)
    final response = await httpClient.get(logoutUrl);
    if (response.statusCode != 200 && response.statusCode != 302) {
      throw Exception(
        'Logout failed with status ${response.statusCode}: ${response.body}',
      );
    }

    return logoutUrl;
  }

  /// Validates that required logout parameters are present and valid.
  ///
  /// Required parameters:
  /// - client_id: Must be non-empty
  /// - post_logout_redirect_uri: Must be non-empty
  ///
  /// Throws [ArgumentError] if any validation fails.
  void _validatePayload(Map<String, String> payload) {
    if (!payload.containsKey('client_id') || payload['client_id']!.isEmpty) {
      throw ArgumentError('Missing required parameter: client_id');
    }
    if (!payload.containsKey('post_logout_redirect_uri') ||
        payload['post_logout_redirect_uri']!.isEmpty) {
      throw ArgumentError(
        'Missing required parameter: post_logout_redirect_uri',
      );
    }
  }
}
