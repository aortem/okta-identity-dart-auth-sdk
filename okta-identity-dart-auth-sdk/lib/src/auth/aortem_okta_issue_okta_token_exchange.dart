import 'dart:async';
import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// A consumer-style class to handle OAuth 2.0 token exchange and refresh operations with Okta.
///
/// This class implements the OAuth 2.0 token endpoint for:
/// - Authorization code exchange (for code flow)
/// - Refresh token requests
/// - Other OAuth 2.0 grant types supported by Okta
///
/// The consumer pattern allows flexible configuration of token requests while
/// maintaining required parameters and validation.
class OktaTokenExchangeConsumer {
  /// The base domain URL of the Okta authorization server
  /// (e.g., 'https://your-org.okta.com')
  final String oktaDomain;

  /// The client ID of the OAuth application registered in Okta
  final String clientId;

  /// The client secret (required for confidential clients, optional for public clients)
  final String? clientSecret;

  /// The redirect URI registered in the Okta application
  final String redirectUri;

  /// Creates an instance of [OktaTokenExchangeConsumer].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base URL of your Okta organization
  /// - [clientId]: The client ID of your Okta OAuth application
  /// - [redirectUri]: The redirect URI registered in your Okta application
  ///
  /// Optional parameter:
  /// - [clientSecret]: The client secret for confidential clients
  OktaTokenExchangeConsumer({
    required this.oktaDomain,
    required this.clientId,
    required this.redirectUri,
    this.clientSecret,
  });

  /// Performs OAuth 2.0 token exchange or refresh operation.
  ///
  /// The [modifyPayload] callback allows customization of the token request parameters
  /// while ensuring required fields are present. The base payload includes:
  /// - client_id: The application client ID
  /// - redirect_uri: The registered redirect URI
  /// - client_secret: If configured (for confidential clients)
  ///
  /// The callback must provide:
  /// - grant_type: The OAuth 2.0 grant type ('authorization_code', 'refresh_token', etc.)
  /// - Additional parameters specific to the grant type:
  ///   - For 'authorization_code': code
  ///   - For 'refresh_token': refresh_token
  ///
  /// Example usage for authorization code exchange:
  /// ```dart
  /// final tokenExchange = OktaTokenExchangeConsumer(
  ///   oktaDomain: 'https://your-org.okta.com',
  ///   clientId: '0oa1a2b3c4d5e6f7g8h9',
  ///   redirectUri: 'com.example.app:/callback',
  /// );
  ///
  /// final tokens = await tokenExchange.exchangeToken((payload) async {
  ///   payload['grant_type'] = 'authorization_code';
  ///   payload['code'] = authorizationCode;
  ///   payload['code_verifier'] = codeVerifier; // For PKCE
  /// });
  /// ```
  ///
  /// Example usage for refresh token:
  /// ```dart
  /// final tokens = await tokenExchange.exchangeToken((payload) async {
  ///   payload['grant_type'] = 'refresh_token';
  ///   payload['refresh_token'] = storedRefreshToken;
  ///   payload['scope'] = 'openid profile email'; // Optional: request specific scopes
  /// });
  /// ```
  ///
  /// Returns a [Map] containing the token response (access_token, refresh_token, etc.)
  /// on successful exchange.
  ///
  /// Throws [ArgumentError] if:
  /// - Required parameters are missing for the specified grant type
  /// - The grant_type parameter is missing
  ///
  /// Throws [Exception] if the token exchange request fails.
  Future<Map<String, dynamic>> exchangeToken({
    required FutureOr<void> Function(Map<String, String> payload) modifyPayload,
  }) async {
    // Base payload with required OAuth2 parameters
    final Map<String, String> payload = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
    };

    // Add client secret if configured (for confidential clients)
    if (clientSecret != null) {
      payload['client_secret'] = clientSecret!;
    }

    // Allow consumer to modify the payload (sync or async)
    await modifyPayload(payload);

    // Validate required parameters based on grant type
    final grantType = payload['grant_type'];
    if (grantType == null) {
      throw ArgumentError('Missing "grant_type" in token request payload.');
    }

    if (grantType == 'authorization_code' && payload['code'] == null) {
      throw ArgumentError('Missing "code" for authorization_code grant type.');
    }

    if (grantType == 'refresh_token' && payload['refresh_token'] == null) {
      throw ArgumentError(
        'Missing "refresh_token" for refresh_token grant type.',
      );
    }

    final uri = Uri.parse('$oktaDomain/oauth2/default/v1/token');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Token exchange failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to exchange token: $e');
    }
  }
}
