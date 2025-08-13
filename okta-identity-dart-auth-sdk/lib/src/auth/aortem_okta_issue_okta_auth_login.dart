/// Ticket #2 - OktaIdentityAuthLogin: Implement Username/Password Authentication via Consumer Pattern
/// Provides dynamic and flexible API for username/password login.

import 'dart:async';
import 'dart:convert';
import 'package:okta_identity_dart_auth_sdk/src/exception/okta_issue_okta_auth_login_exception.dart';
import 'package:okta_identity_dart_auth_sdk/src/model/okta_issue_okta_auth_login_model.dart';
import '../base/okta_issue_okta_base_sdk_setup.dart';

/// Provides username/password authentication support for OktaIdentity using a consumer pattern.
///
/// This class implements the Resource Owner Password Credentials flow (ROPC) for OktaIdentity,
/// allowing users to authenticate with username and password credentials.
///
/// The consumer pattern provides flexibility in constructing the authentication payload.
class OktaIdentityAuthLoginConsumer {
  final OktaIdentityBaseSDK _baseSDK;

  /// Creates an instance of [OktaIdentityAuthLoginConsumer] with the given [baseSDK].
  ///
  /// The [baseSDK] provides the base configuration (client ID, domain, etc.)
  /// needed for authentication.
  OktaIdentityAuthLoginConsumer(this._baseSDK);

  /// Authenticates a user with username and password credentials.
  ///
  /// Uses a consumer pattern to allow flexible construction of the authentication payload.
  /// The consumer must provide 'username' and 'password' fields in the payload.
  ///
  /// Example usage:
  /// ```dart
  /// final consumer = OktaIdentityAuthLoginConsumer(sdk);
  /// final tokens = await consumer.signIn((payload) {
  ///   payload['username'] = 'user@example.com';
  ///   payload['password'] = 'securePassword123';
  ///   payload['scope'] = 'openid profile offline_access'; // Optional: override default scope
  /// });
  /// ```
  ///
  /// Throws [OktaIdentityAuthPayloadException] if the payload is missing required fields.
  /// Throws [Exception] if the authentication request fails.
  ///
  /// Returns [OktaIdentityTokenResponse] containing the authentication tokens on success.
  Future<OktaIdentityTokenResponse> signIn(
    void Function(Map<String, dynamic>) payloadConsumer,
  ) async {
    // Base payload with required OAuth2 parameters
    final Map<String, dynamic> payload = {
      'grant_type': 'password',
      'scope': 'openid profile email', // Default scope
      'client_id': _baseSDK.config.clientId,
      'redirect_uri': _baseSDK.config.redirectUri,
      'client_secret': _baseSDK.config.clientSecret,
    };

    // Apply consumer to customize the payload
    payloadConsumer(payload);

    // Validate that required fields are present
    if (!payload.containsKey('username') || !payload.containsKey('password')) {
      throw OktaIdentityAuthPayloadException(
        'Payload must include both "username" and "password" fields.',
      );
    }
    print('[DEBUG] oktaIdentityDomain: ${_baseSDK.oktaIdentityDomain}');

    // Construct the token endpoint URL
    final uri = Uri.parse(
      '${_baseSDK.config.oktaIdentityDomain}/oauth2/default/v1/token',
    );
    print('[DEBUG] Token URL: $uri');
    // Send the authentication request
    final response = await _baseSDK.httpClient.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: payload.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
          )
          .join('&'),
    );

    // Process the response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OktaIdentityTokenResponse.fromJson(data);
    } else {
      throw Exception(
        'Authentication failed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
