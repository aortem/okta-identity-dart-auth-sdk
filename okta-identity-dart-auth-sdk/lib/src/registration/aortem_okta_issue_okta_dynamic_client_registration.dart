import 'dart:async';
import 'dart:convert';

import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// Handles Dynamic Client Registration with Okta's OAuth 2.0/OIDC endpoints.
///
/// This class implements the OAuth 2.0 Dynamic Client Registration Protocol
/// (RFC 7591) for programmatically registering clients with Okta's authorization
/// server.
///
/// Typical use cases include:
/// - On-demand client registration for multi-tenant applications
/// - Automated client provisioning in CI/CD pipelines
/// - Temporary client registration for testing purposes
class AortemOktaDynamicClientRegistration {
  /// The base domain of the Okta organization
  /// (e.g., 'your-org.okta.com' or 'https://your-org.okta.com')
  final String oktaDomain;

  /// The HTTP client used for making registration requests
  final http.Client httpClient;

  /// Creates an instance of [AortemOktaDynamicClientRegistration].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base domain of your Okta organization
  ///
  /// Optional parameters:
  /// - [httpClient]: Custom HTTP client instance (defaults to [http.Client])
  AortemOktaDynamicClientRegistration({
    required this.oktaDomain,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Registers a new OAuth client with Okta's dynamic registration endpoint.
  ///
  /// Uses a consumer pattern to allow flexible client configuration while
  /// ensuring required fields are present. The base payload includes:
  /// - `application_type`: 'web' (default)
  /// - `redirect_uris`: Empty list (must be populated by consumer)
  ///
  /// Example usage:
  /// ```dart
  /// final registration = AortemOktaDynamicClientRegistration(
  ///   oktaDomain: 'your-org.okta.com',
  /// );
  ///
  /// final clientMetadata = await registration.registerClient((payload) {
  ///   payload['redirect_uris'] = [
  ///     'https://your-app.com/callback',
  ///     'com.your.app:/callback'
  ///   ];
  ///   payload['client_name'] = 'Your Application';
  ///   payload['grant_types'] = ['authorization_code', 'refresh_token'];
  ///   payload['response_types'] = ['code'];
  /// });
  /// ```
  ///
  /// @param configure A callback that receives and can modify the registration payload
  /// @return [Future<Map<String, dynamic>>] A map containing the registered client metadata
  ///         (client_id, client_secret, registration_access_token, etc.)
  /// @throws [ArgumentError] if required fields are missing
  /// @throws [Exception] if registration fails or network error occurs
  Future<Map<String, dynamic>> registerClient(
    void Function(Map<String, dynamic>) configure,
  ) async {
    // Base payload with required fields and defaults
    final payload = <String, dynamic>{
      'redirect_uris': [], // Must be populated by consumer
      'application_type': 'web', // Default application type
    };

    // Allow consumer to customize the registration payload
    configure(payload);

    // Validate required fields
    if (payload['redirect_uris'] == null || payload['redirect_uris'].isEmpty) {
      throw ArgumentError(
        'At least one redirect_uri is required for client registration',
      );
    }

    final uri = Uri.https(oktaDomain, '/oauth2/v1/clients');

    try {
      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 201) {
        throw Exception(
          'Client registration failed with status ${response.statusCode}: ${response.body}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Dynamic client registration failed: $e');
    }
  }
}
