// File: lib/aortem-okta-global-token-revocation-consumer.dart

import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:okta_identity_dart_auth_sdk/src/exception/okta_issue_revocation_exception.dart';
import '../exception/okta_issue_missing_token_exception.dart';

/// Builder class for constructing token revocation payloads.
///
/// This builder implements a fluent interface for creating properly formatted
/// token revocation requests according to OAuth 2.0 Token Revocation (RFC 7009).
///
/// The builder ensures:
/// - Required fields are present
/// - Proper parameter formatting
/// - Valid token type hints
///
/// Example Usage:
/// ```dart
/// final builder = OktaIdentityTokenRevocationPayloadBuilder()
///   ..setToken('eyJhbGciOiJSUzI1NiIs...')
///   ..setTokenTypeHint('refresh_token');
/// final payload = builder.build();
/// ```
class OktaIdentityTokenRevocationPayloadBuilder {
  /// The token to be revoked (required)
  String? token;

  /// Optional hint about the token type
  String? tokenTypeHint;

  /// Sets the OAuth 2.0 token to be revoked.
  ///
  /// This is a required field for all revocation requests.
  ///
  /// @param value The token string to revoke
  /// @return void
  void setToken(String value) => token = value;

  /// Sets an optional hint about the token type.
  ///
  /// Valid values are:
  /// - 'access_token'
  /// - 'refresh_token'
  ///
  /// While optional, providing this hint can improve revocation performance.
  ///
  /// @param value The token type hint
  /// @return void
  void setTokenTypeHint(String value) => tokenTypeHint = value;

  /// Constructs the final revocation payload.
  ///
  /// Validates that required fields are present and returns a properly
  /// formatted Map for use in revocation requests.
  ///
  /// @return Map<String, String> The formatted revocation payload
  /// @throws MissingTokenFieldException If token is null or empty
  Map<String, String> build() {
    if (token == null || token!.isEmpty) {
      throw MissingTokenFieldException();
    }
    final payload = {'token': token!};
    if (tokenTypeHint != null) {
      payload['token_type_hint'] = tokenTypeHint!;
    }
    return payload;
  }
}

/// Provides global token revocation functionality for OktaIdentity OAuth 2.0 tokens.
///
/// This class implements the OAuth 2.0 Token Revocation (RFC 7009) specification
/// to programmatically revoke tokens across all sessions and devices.
///
/// Key Features:
/// - Supports revocation of both access and refresh tokens
/// - Implements proper Basic Authentication with client credentials
/// - Validates all requests before sending
/// - Provides clear error reporting
/// - Uses builder pattern for flexible payload construction
///
/// Security Considerations:
/// - Requires proper client credentials
/// - Should only be used with HTTPS connections
/// - Tokens are immediately invalidated globally
class OktaIdentityGlobalTokenRevocationConsumer {
  /// The base domain of the OktaIdentity organization
  ///
  /// Example: 'your-org.okta.com'
  final String oktaIdentityDomain;

  /// The client ID registered in your OktaIdentity application
  final String clientId;

  /// The client secret for confidential clients
  ///
  /// Required for applications that are not public clients.
  final String? clientSecret;

  /// The HTTP client used for making revocation requests
  final http.Client _httpClient;

  /// Creates a new token revocation consumer instance.
  ///
  /// Required Parameters:
  /// - [oktaIdentityDomain]: Your OktaIdentity organization's domain (e.g., 'your-org.okta.com')
  /// - [clientId]: The client ID of your registered OktaIdentity application
  ///
  /// Optional Parameters:
  /// - [clientSecret]: Required for confidential clients (default: null)
  /// - [httpClient]: Custom HTTP client instance (default: creates new client)
  ///
  /// Example:
  /// ```dart
  /// final revoker = OktaIdentityGlobalTokenRevocationConsumer(
  ///   oktaIdentityDomain: 'your-org.okta.com',
  ///   clientId: '0oa1a2b3c4d5e6f7g8h9',
  ///   clientSecret: 'your-secret-here',
  /// );
  /// ```
  OktaIdentityGlobalTokenRevocationConsumer({
    required this.oktaIdentityDomain,
    required this.clientId,
    this.clientSecret,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Revokes an OAuth 2.0 token globally across all sessions and devices.
  ///
  /// This method performs the following operations:
  /// 1. Constructs the revocation payload using the builder pattern
  /// 2. Validates all required fields
  /// 3. Sends the revocation request to OktaIdentity's OAuth 2.0 revocation endpoint
  /// 4. Verifies the response status
  ///
  /// Parameters:
  /// - [buildPayload]: A callback that receives and configures the payload builder
  ///
  /// Returns:
  /// Future<void> that completes when revocation is successful
  ///
  /// Throws:
  /// - [MissingTokenFieldException] if token is not provided
  /// - [OktaIdentityRevocationException] if the API request fails
  ///
  /// Example:
  /// ```dart
  /// await revoker.revokeToken(
  ///   buildPayload: (builder) {
  ///     builder.setToken('eyJhbGciOiJSUzI1NiIs...');
  ///     builder.setTokenTypeHint('refresh_token');
  ///   },
  /// );
  /// ```
  Future<void> revokeToken({
    required void Function(OktaIdentityTokenRevocationPayloadBuilder builder)
    buildPayload,
  }) async {
    // Create and configure the payload builder
    final builder = OktaIdentityTokenRevocationPayloadBuilder();
    buildPayload(builder);
    final payload = builder.build();

    // Prepare request headers with Basic Auth
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$clientId:${clientSecret ?? ''}'))}',
    };

    // Construct the revocation endpoint URI
    final uri = Uri.parse('$oktaIdentityDomain/oauth2/default/v1/revoke');

    // Execute the revocation request
    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: payload,
    );

    // Validate the response
    if (response.statusCode != 200) {
      throw OktaIdentityRevocationException(
        'Failed to revoke token. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
