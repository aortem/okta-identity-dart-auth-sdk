import 'dart:convert';

import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// Handles Okta authorization flows using OpenID Connect protocol.
///
/// This class provides methods for:
/// - Constructing authorization URLs for user redirection
/// - Exchanging authorization codes for tokens
/// - Managing OAuth 2.0 and OpenID Connect authentication flows
///
/// Supports both public clients (without client secret) and confidential clients
/// (with client secret).
class AortemOktaAuthorization {
  /// The client ID registered in your Okta application
  final String clientId;

  /// The redirect URI registered in your Okta application
  final String redirectUri;

  /// The base domain of your Okta organization (e.g. 'your-domain.okta.com')
  final String oktaDomain;

  /// The client secret for confidential clients (optional for public clients)
  final String? clientSecret;

  /// The HTTP client used for making requests
  final http.Client _httpClient;

  /// Creates an instance of [AortemOktaAuthorization].
  ///
  /// Required parameters:
  /// - [clientId]: Your Okta application's client ID
  /// - [redirectUri]: The registered redirect URI
  /// - [oktaDomain]: Your Okta organization domain
  ///
  /// Optional parameters:
  /// - [clientSecret]: Required for confidential clients
  /// - [httpClient]: Custom HTTP client (defaults to standard [http.Client])
  AortemOktaAuthorization({
    required this.clientId,
    required this.redirectUri,
    required this.oktaDomain,
    this.clientSecret,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Constructs an authorization URL for redirecting users to Okta login.
  ///
  /// Uses a consumer pattern to allow customization of OAuth parameters while
  /// ensuring required fields are present. Default parameters include:
  /// - response_type: 'code' (authorization code flow)
  /// - scope: 'openid profile email' (basic OpenID Connect scopes)
  ///
  /// Example:
  /// ```dart
  /// final auth = AortemOktaAuthorization(
  ///   clientId: 'your_client_id',
  ///   redirectUri: 'com.example.app:/callback',
  ///   oktaDomain: 'your-domain.okta.com',
  /// );
  ///
  /// final url = auth.authorizeApplication((params) {
  ///   params['scope'] = 'openid profile email offline_access';
  ///   params['state'] = 'random-state-value';
  ///   params['prompt'] = 'login';
  /// });
  /// ```
  ///
  /// @param customize A callback that receives and can modify the authorization parameters
  /// @return [Uri] The complete authorization URL
  /// @throws [ArgumentError] if required parameters are missing
  Uri authorizeApplication(void Function(Map<String, String>) customize) {
    final params = <String, String>{
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code', // Default to authorization code flow
      'scope': 'openid profile email', // Basic OpenID Connect scopes
    };

    // Let consumer customize parameters
    customize(params);

    // Validate required fields
    const required = ['client_id', 'redirect_uri', 'response_type'];
    for (final key in required) {
      if (!params.containsKey(key) || params[key]!.trim().isEmpty) {
        throw ArgumentError('Missing required authorization parameter: $key');
      }
    }

    return Uri.https(oktaDomain, '/oauth2/v1/authorize', params);
  }

  /// Exchanges an authorization code for tokens using the token endpoint.
  ///
  /// This completes the authorization code flow by exchanging the code for
  /// access, ID, and refresh tokens. Uses a consumer pattern to allow
  /// customization of the token request while ensuring required fields are present.
  ///
  /// Example:
  /// ```dart
  /// final tokens = await auth.authorizeEndpoint((params) {
  ///   params['code'] = 'auth-code-from-okta';
  ///   params['code_verifier'] = 'your-code-verifier'; // For PKCE
  /// });
  /// ```
  ///
  /// @param customize A callback that receives and can modify the token request parameters
  /// @return [Future<Map<String, dynamic>>] A map containing the token response
  /// @throws [ArgumentError] if required 'code' parameter is missing
  /// @throws [Exception] if the token exchange fails or network error occurs
  Future<Map<String, dynamic>> authorizeEndpoint(
    void Function(Map<String, String>) customize,
  ) async {
    final body = <String, String>{
      'grant_type': 'authorization_code',
      'redirect_uri': redirectUri,
      'client_id': clientId,
    };

    // Add client secret if this is a confidential client
    if (clientSecret != null) {
      body['client_secret'] = clientSecret!;
    }

    // Let consumer customize/add parameters
    customize(body);

    if (!body.containsKey('code') || body['code']!.trim().isEmpty) {
      throw ArgumentError('Missing required field: code');
    }

    final uri = Uri.https(oktaDomain, '/oauth2/v1/token');

    try {
      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Token exchange failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network or authorization error: $e');
    }
  }
}
