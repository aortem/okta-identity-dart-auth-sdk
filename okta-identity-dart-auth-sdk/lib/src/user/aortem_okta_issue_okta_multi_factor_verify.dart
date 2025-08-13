import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// Provides token revocation functionality for OktaIdentity OAuth 2.0 tokens.
///
/// This class implements the OAuth 2.0 Token Revocation (RFC 7009) specification
/// to programmatically revoke both access and refresh tokens issued by OktaIdentity.
///
/// Features:
/// - Revokes both access and refresh tokens
/// - Supports token type hints for optimized revocation
/// - Implements Basic Authentication for client credentials
/// - Validates input parameters
class OktaIdentityTokenRevocation {
  /// The base domain of the OktaIdentity organization (e.g., 'your-org.okta.com')
  final String oktaIdentityDomain;

  /// The client ID of the OktaIdentity OAuth application
  final String clientId;

  /// The client secret (required for confidential clients)
  final String? clientSecret;

  /// The HTTP client used for making revocation requests
  final http.Client httpClient;

  /// Creates an instance of [OktaIdentityTokenRevocation].
  ///
  /// Required parameters:
  /// - [oktaIdentityDomain]: The base domain of your OktaIdentity organization
  /// - [clientId]: The client ID of your OktaIdentity application
  ///
  /// Optional parameters:
  /// - [clientSecret]: Required for confidential clients
  /// - [httpClient]: Custom HTTP client (defaults to standard [http.Client])
  OktaIdentityTokenRevocation({
    required this.oktaIdentityDomain,
    required this.clientId,
    this.clientSecret,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Revokes an OAuth 2.0 token (access or refresh token).
  ///
  /// This method calls OktaIdentity's OAuth 2.0 revocation endpoint to immediately
  /// invalidate the specified token. Both access and refresh tokens can be revoked.
  ///
  /// Example:
  /// ```dart
  /// final revoker = OktaIdentityTokenRevocation(
  ///   oktaIdentityDomain: 'your-org.okta.com',
  ///   clientId: '0oa1a2b3c4d5e6f7g8h9',
  ///   clientSecret: 'your-client-secret',
  /// );
  ///
  /// await revoker.revokeToken(
  ///   token: 'eyJhbGciOiJSUzI1NiIs...',
  ///   tokenTypeHint: 'refresh_token',
  /// );
  /// ```
  ///
  /// @param token The access or refresh token to revoke (required)
  /// @param tokenTypeHint Optional hint about the token type ('access_token' or 'refresh_token')
  /// @return [Future<void>]
  /// @throws ArgumentError If token is empty
  /// @throws Exception If revocation fails (network error or server error)
  Future<void> revokeToken({
    required String token,
    String? tokenTypeHint,
  }) async {
    if (token.isEmpty) {
      throw ArgumentError('Token must not be empty.');
    }

    final uri = Uri.https(oktaIdentityDomain, '/oauth2/default/v1/revoke');

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': _buildBasicAuthHeader(),
    };

    final body = {
      'token': token,
      if (tokenTypeHint != null) 'token_type_hint': tokenTypeHint,
    };

    final response = await httpClient.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to revoke token. Status: ${response.statusCode}. Body: ${response.body}',
      );
    }
  }

  /// Builds the Basic Authentication header for client credentials.
  ///
  /// Constructs the Authorization header value using the client ID and secret
  /// following RFC 7617 (The 'Basic' HTTP Authentication Scheme).
  ///
  /// @return [String] The Basic Auth header value
  String _buildBasicAuthHeader() {
    final creds = '$clientId:${clientSecret ?? ''}';
    final encoded = base64.encode(utf8.encode(creds));
    return 'Basic $encoded';
  }
}
