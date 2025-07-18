import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// Callback type for building custom payloads when adding authenticators.
///
/// This typedef defines a function signature that returns a [Map<String, dynamic>]
/// containing the authenticator configuration. Used by [addAuthenticator] to allow
/// flexible authenticator configuration.
typedef AuthenticatorPayloadBuilder = Map<String, dynamic> Function();

/// Manages Okta user authenticators (factors) through Okta's Factors API.
///
/// This class provides methods to:
/// - Add new authenticators (SMS, TOTP, Push Notification, etc.)
/// - List registered authenticators for a user
/// - Delete existing authenticators
///
/// Requires an Okta API token with appropriate permissions.
class AortemOktaAuthenticatorManagement {
  /// The base domain of the Okta organization (e.g., 'your-org.okta.com')
  final String oktaDomain;

  /// The Okta API token used for authentication
  final String apiToken;

  /// The HTTP client used for making requests
  final http.Client _httpClient;

  /// Creates an instance of [AortemOktaAuthenticatorManagement].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base domain of your Okta organization
  /// - [apiToken]: A valid Okta API token with factors management permissions
  ///
  /// Optional parameters:
  /// - [httpClient]: Custom HTTP client instance (defaults to [http.Client])
  AortemOktaAuthenticatorManagement({
    required this.oktaDomain,
    required this.apiToken,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Adds a new authenticator (factor) to a user's profile.
  ///
  /// Uses a builder pattern to allow flexible authenticator configuration.
  /// The [payloadBuilder] must return a payload containing at minimum:
  /// - authenticatorType: The type of authenticator (e.g., 'sms', 'token:software:totp')
  ///
  /// Example:
  /// ```dart
  /// final authManager = AortemOktaAuthenticatorManagement(
  ///   oktaDomain: 'your-org.okta.com',
  ///   apiToken: 'your_api_token',
  /// );
  ///
  /// final response = await authManager.addAuthenticator(
  ///   userId: '00u1a2b3c4d5e6f7g8h9',
  ///   payloadBuilder: () => {
  ///     'authenticatorType': 'sms',
  ///     'profile': {
  ///       'phoneNumber': '+15551234567'
  ///     }
  ///   },
  /// );
  /// ```
  ///
  /// @param userId The ID of the user to add the authenticator to
  /// @param payloadBuilder Callback that returns the authenticator configuration
  /// @return [Future<Map<String, dynamic>>] The created authenticator details
  /// @throws ArgumentError If userId is empty or payload is missing required fields
  /// @throws Exception If the API request fails
  Future<Map<String, dynamic>> addAuthenticator({
    required String userId,
    required AuthenticatorPayloadBuilder payloadBuilder,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId is required.');

    final payload = payloadBuilder();
    if (!payload.containsKey('authenticatorType')) {
      throw ArgumentError('authenticatorType is required in the payload.');
    }

    final url = Uri.parse('https://$oktaDomain/api/v1/users/$userId/factors');

    try {
      final response = await _httpClient.post(
        url,
        headers: {
          'Authorization': 'SSWS $apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to add authenticator: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error adding authenticator: $e');
    }
  }

  /// Lists all authenticators registered for a user.
  ///
  /// Example:
  /// ```dart
  /// final authenticators = await authManager.listAuthenticators(
  ///   userId: '00u1a2b3c4d5e6f7g8h9',
  /// );
  /// ```
  ///
  /// @param userId The ID of the user to list authenticators for
  /// @return [Future<List<Map<String, dynamic>>>] List of authenticator details
  /// @throws ArgumentError If userId is empty
  /// @throws Exception If the API request fails
  Future<List<Map<String, dynamic>>> listAuthenticators({
    required String userId,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId is required.');

    final url = Uri.parse('https://$oktaDomain/api/v1/users/$userId/factors');

    try {
      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'SSWS $apiToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        } else {
          throw Exception('Unexpected response format: $body');
        }
      } else {
        throw Exception(
          'Failed to list authenticators: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error listing authenticators: $e');
    }
  }

  /// Deletes a specific authenticator for a user.
  ///
  /// Example:
  /// ```dart
  /// await authManager.deleteAuthenticator(
  ///   userId: '00u1a2b3c4d5e6f7g8h9',
  ///   factorId: 'opf1a2b3c4d5e6f7g8h9',
  /// );
  /// ```
  ///
  /// @param userId The ID of the user who owns the authenticator
  /// @param factorId The ID of the authenticator to delete
  /// @return [Future<void>]
  /// @throws ArgumentError If userId or factorId are empty
  /// @throws Exception If the API request fails
  Future<void> deleteAuthenticator({
    required String userId,
    required String factorId,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId is required.');
    if (factorId.isEmpty) throw ArgumentError('factorId is required.');

    final url =
        Uri.parse('https://$oktaDomain/api/v1/users/$userId/factors/$factorId');

    try {
      final response = await _httpClient.delete(
        url,
        headers: {
          'Authorization': 'SSWS $apiToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw Exception(
          'Failed to delete authenticator: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting authenticator: $e');
    }
  }
}
