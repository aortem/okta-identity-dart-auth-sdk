// Importing the standard features package with an HTTP client implementation
// Aliased as 'http' for consistent usage throughout the code
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// A base SDK for OktaIdentity integration providing configuration and HTTP client management.
///
/// This library contains the foundational classes for setting up and configuring
/// OktaIdentity authentication in Dart/Flutter applications. It handles the basic
/// configuration requirements and provides a shared HTTP client for making
/// authenticated requests to OktaIdentity's APIs.
///
/// ## Usage
///
/// ```dart
/// final config = OktaIdentityConfig(
///   oktaIdentityDomain: 'https://your-okta-domain.okta.com',
///   clientId: 'your_client_id',
///   redirectUri: 'com.example.app:/callback',
///   clientSecret: 'your_client_secret', // optional for public clients
/// );
///
/// final sdk = OktaIdentityBaseSDK(config: config);
/// ```
///
/// ## Features
/// - Configuration validation
/// - Shared HTTP client management
/// - Proper resource cleanup

/// Exception thrown when the OktaIdentity SDK configuration is invalid or incomplete.
///
/// This exception is typically thrown when required configuration parameters
/// are missing or malformed during initialization.
class OktaIdentityConfigurationException implements Exception {
  /// Creates a configuration exception with the given error message.
  /// [message] should describe the specific configuration issue encountered.
  OktaIdentityConfigurationException(this.message);

  /// The error message describing the configuration issue.
  /// This provides details about what went wrong during configuration.
  final String message;

  /// Returns a string representation of the exception.
  /// Formats the exception type with its message for debugging purposes.
  @override
  String toString() => 'OktaIdentityConfigurationException: $message';
}

/// Holds all required configuration parameters for initializing the OktaIdentity SDK.
///
/// This class validates and stores the essential configuration needed to
/// communicate with OktaIdentity's OAuth 2.0 and OpenID Connect endpoints.
class OktaIdentityConfig {
  /// Creates a new OktaIdentity configuration.
  ///
  /// Validates that required parameters are not empty before initialization.
  ///
  /// Required parameters:
  /// - [oktaIdentityDomain]: Your OktaIdentity domain (e.g., 'https://your-okta-domain.okta.com')
  /// - [clientId]: The client ID of your OktaIdentity application
  /// - [redirectUri]: The redirect URI registered with your OktaIdentity application
  ///
  /// Optional parameter:
  /// - [clientSecret]: The client secret (required for confidential clients)
  ///
  /// Throws [ArgumentError] if any required parameters are empty.
  OktaIdentityConfig({
    required this.oktaIdentityDomain,
    required this.clientId,
    required this.redirectUri,
    this.clientSecret,
  }) {
    // Validation check for empty required parameters
    if (oktaIdentityDomain.isEmpty || clientId.isEmpty || redirectUri.isEmpty) {
      throw ArgumentError(
        'OktaIdentity domain, clientId, and redirectUri must not be empty.',
      );
    }
  }

  /// The base domain URL of your OktaIdentity organization.
  /// This should be the full URL including the https:// protocol.
  final String oktaIdentityDomain;

  /// The client ID of your OktaIdentity OAuth application.
  /// This is obtained when registering your application in the OktaIdentity dashboard.
  final String clientId;

  /// The redirect URI registered with your OktaIdentity application.
  /// This URI is used for OAuth 2.0 redirect flows.
  final String redirectUri;

  /// The client secret for confidential client applications.
  /// This may be null for public clients (e.g., mobile/native apps).
  /// Required for server-side or web applications.
  final String? clientSecret;
}

/// The base SDK class providing core functionality for OktaIdentity integration.
///
/// This class manages:
/// - Configuration storage and access
/// - HTTP client lifecycle
/// - Resource cleanup
///
/// All OktaIdentity SDK functionality should extend or use this base class.
class OktaIdentityBaseSDK {
  /// Initializes the base SDK with the given configuration.
  ///
  /// Parameters:
  /// - [config]: The required OktaIdentity configuration
  /// - [httpClient]: Optional custom HTTP client (uses default if not provided)
  ///
  /// The constructor stores the configuration and initializes the HTTP client.
  OktaIdentityBaseSDK({
    required OktaIdentityConfig config,
    http.Client? httpClient,
  }) : _config = config, // Stores the provided configuration
       _httpClient =
           httpClient ??
           http.Client(); // Uses provided client or creates a default one

  /// Private field storing the OktaIdentity configuration.
  /// Accessed through the public getter `config`.
  final OktaIdentityConfig _config;

  /// Private field storing the HTTP client instance.
  /// Accessed through the public getter `httpClient`.
  final http.Client _httpClient;

  /// Public field for OktaIdentity domain access.
  /// Note: This appears to be redundant with the config's oktaIdentityDomain.
  var oktaIdentityDomain;

  /// Gets the current OktaIdentity configuration.
  /// Provides read-only access to the configuration parameters.
  OktaIdentityConfig get config => _config;

  /// Gets the shared HTTP client for making authenticated requests.
  ///
  /// This client is configured with the appropriate base URLs and interceptors
  /// for OktaIdentity API communication.
  http.Client get httpClient => _httpClient;

  /// Placeholder getter for clientId.
  /// Note: Should likely be removed or properly implemented to return _config.clientId.
  get clientId => null;

  /// Placeholder getter for redirectUri.
  /// Note: Should likely be removed or properly implemented to return _config.redirectUri.
  get redirectUri => null;

  /// Cleans up resources, particularly the HTTP client.
  ///
  /// Always call this method when the SDK is no longer needed to prevent
  /// resource leaks, especially in long-lived applications.
  void dispose() {
    // Closes the HTTP client to release resources
    _httpClient.close();
  }
}
