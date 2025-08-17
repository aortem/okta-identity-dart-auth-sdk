import 'dart:async';
import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:okta_identity_dart_auth_sdk/src/exception/okta_issue_okta_api_exception.dart';
import 'package:okta_identity_dart_auth_sdk/src/exception/okta_issue_okta_missing_feild_exception.dart';

/// Builder pattern class for constructing OktaIdentity user requests.
///
/// Provides a fluent interface for setting user properties and credentials
/// when creating or updating OktaIdentity user accounts.
class OktaIdentityUserRequestBuilder {
  final Map<String, dynamic> _data = {
    'profile': {},
    'credentials': {'password': <String, dynamic>{}},
  };

  /// Sets the user's email address
  void setEmail(String email) => _data['profile']['email'] = email;

  /// Sets the user's login identifier
  void setLogin(String login) => _data['profile']['login'] = login;

  /// Sets the user's first name
  void setFirstName(String firstName) =>
      _data['profile']['firstName'] = firstName;

  /// Sets the user's last name
  void setLastName(String lastName) => _data['profile']['lastName'] = lastName;

  /// Sets the user's password
  void setPassword(String password) {
    (_data['credentials']['password'] ??= {})['value'] = password;
  }

  /// Sets a custom profile field
  void setProfileField(String key, dynamic value) =>
      _data['profile'][key] = value;

  /// Builds the final user data payload
  Map<String, dynamic> build() => _data;
}

/// Provides consumer-style user management operations for OktaIdentity.
///
/// This class implements OktaIdentity's User API with a consumer pattern for
/// flexible request building. Supports:
/// - User registration
/// - Profile retrieval
/// - Password changes
class OktaIdentityUserManagementConsumer {
  /// The base domain of the OktaIdentity organization (e.g., 'your-org.okta.com')
  final String oktaIdentityDomain;

  /// The OktaIdentity API token with user management permissions
  final String apiToken;

  /// Creates an [OktaIdentityUserManagementConsumer] instance.
  ///
  /// Required parameters:
  /// - [oktaIdentityDomain]: Your OktaIdentity organization domain
  /// - [apiToken]: An API token with sufficient permissions
  OktaIdentityUserManagementConsumer({
    required this.oktaIdentityDomain,
    required this.apiToken,
  });

  /// Registers a new user with OktaIdentity using a consumer pattern.
  ///
  /// Example:
  /// ```dart
  /// final user = await consumer.signUp(
  ///   buildPayload: (builder) async {
  ///     builder.setEmail('user@example.com');
  ///     builder.setLogin('user@example.com');
  ///     builder.setPassword('SecurePassword123!');
  ///     builder.setFirstName('John');
  ///     builder.setLastName('Doe');
  ///   },
  ///   activate: true,
  /// );
  /// ```
  ///
  /// @param buildPayload Consumer callback to configure the user properties
  /// @param activate Whether to immediately activate the user (default: true)
  /// @return User profile data
  /// @throws MissingRequiredFieldException If email, login or password is missing
  /// @throws OktaIdentityApiException If the API request fails
  Future<Map<String, dynamic>> signUp({
    required FutureOr<void> Function(OktaIdentityUserRequestBuilder builder)
    buildPayload,
    bool activate = true,
  }) async {
    final builder = OktaIdentityUserRequestBuilder();
    await buildPayload(builder);
    final payload = builder.build();

    // Validate required fields
    final profile = payload['profile'] ?? {};
    final credentials = payload['credentials'] ?? {};
    final password = credentials['password']?['value'];

    if (profile['email'] == null ||
        profile['login'] == null ||
        password == null) {
      throw MissingRequiredFieldException(
        'Missing required fields: email, login, or password.',
      );
    }

    final uri = Uri.parse(
      '$oktaIdentityDomain/api/v1/users?activate=$activate',
    );
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'SSWS $apiToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw OktaIdentityApiException(response.statusCode, response.body);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Retrieves a user's profile by ID.
  ///
  /// @param userId The OktaIdentity user ID
  /// @return User profile data
  /// @throws OktaIdentityApiException If the API request fails
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final uri = Uri.parse('$oktaIdentityDomain/api/v1/users/$userId');
    final response = await http.get(uri, headers: _headers());

    if (response.statusCode >= 400) {
      throw OktaIdentityApiException(response.statusCode, response.body);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Changes a user's password.
  ///
  /// @param userId The OktaIdentity user ID
  /// @param oldPassword The user's current password
  /// @param newPassword The desired new password
  /// @return Operation result
  /// @throws OktaIdentityApiException If the API request fails
  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse(
      '$oktaIdentityDomain/api/v1/users/$userId/credentials/change_password',
    );

    final body = {
      'oldPassword': {'value': oldPassword},
      'newPassword': {'value': newPassword},
    };

    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 400) {
      throw OktaIdentityApiException(response.statusCode, response.body);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Creates standard headers for API requests
  Map<String, String> _headers() => {
    'Authorization': 'SSWS $apiToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
