/// Ticket #2 - OktaAuthLogin: Implement Username/Password Authentication via Consumer Pattern
/// Provides dynamic and flexible API for username/password login.

import 'dart:async';
import 'dart:convert';
import 'package:okta_identity_dart_auth_sdk/src/exception/aortem_okta_issue_okta_auth_login_exception.dart';
import 'package:okta_identity_dart_auth_sdk/src/model/aortem_okta_issue_okta_auth_login_model.dart';
import '../base/aortem_okta_issue_okta_base_sdk_setup.dart';

/// Provides username/password authentication support for Okta using a consumer pattern.
///
/// This class implements the Resource Owner Password Credentials flow (ROPC) for Okta,
/// allowing users to authenticate with username and password credentials.
///
/// The consumer pattern provides flexibility in constructing the authentication payload.
class OktaAuthLoginConsumer {
  final OktaBaseSDK _baseSDK;

  /// Creates an instance of [OktaAuthLoginConsumer] with the given [baseSDK].
  ///
  /// The [baseSDK] provides the base configuration (client ID, domain, etc.)
  /// needed for authentication.
  OktaAuthLoginConsumer(this._baseSDK);

  /// Authenticates a user with username and password credentials.
  ///
  /// Uses a consumer pattern to allow flexible construction of the authentication payload.
  /// The consumer must provide 'username' and 'password' fields in the payload.
  ///
  /// Example usage:
  /// ```dart
  /// final consumer = OktaAuthLoginConsumer(sdk);
  /// final tokens = await consumer.signIn((payload) {
  ///   payload['username'] = 'user@example.com';
  ///   payload['password'] = 'securePassword123';
  ///   payload['scope'] = 'openid profile offline_access'; // Optional: override default scope
  /// });
  /// ```
  ///
  /// Throws [OktaAuthPayloadException] if the payload is missing required fields.
  /// Throws [Exception] if the authentication request fails.
  ///
  /// Returns [OktaTokenResponse] containing the authentication tokens on success.
  Future<OktaTokenResponse> signIn(
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
      throw OktaAuthPayloadException(
        'Payload must include both "username" and "password" fields.',
      );
    }
    print('[DEBUG] oktaDomain: ${_baseSDK.oktaDomain}');

    // Construct the token endpoint URL
    final uri = Uri.parse(
      '${_baseSDK.config.oktaDomain}/oauth2/default/v1/token',
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
      return OktaTokenResponse.fromJson(data);
    } else {
      throw Exception(
        'Authentication failed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
