/// Enables Identity Provider (IdP)-Initiated Single Sign-On (SSO) for Okta.
///
/// This class constructs secure redirect URLs for IdP-initiated SSO flows,
/// allowing Okta (the Identity Provider) to initiate authentication without
/// requiring a service provider request first.
///
/// Features:
/// - Constructs properly formatted IdP-initiated SSO URLs
/// - Validates required parameters
/// - Supports dynamic parameter customization
/// - Handles both default and custom RelayState values
class AortemOktaIdpInitiatedSSO {
  /// The base domain of the Okta organization (e.g., 'your-org.okta.com')
  final String oktaDomain;

  /// The client ID of the Okta OAuth application
  final String clientId;

  /// Optional default RelayState value for SSO redirects
  final String? defaultRelayState;

  /// Creates an instance of [AortemOktaIdpInitiatedSSO].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base domain of your Okta organization
  /// - [clientId]: The client ID of your Okta application
  ///
  /// Optional parameters:
  /// - [defaultRelayState]: Default RelayState value for SSO redirects
  ///
  /// Throws [ArgumentError] if required parameters are empty
  AortemOktaIdpInitiatedSSO({
    required this.oktaDomain,
    required this.clientId,
    this.defaultRelayState,
  }) {
    if (oktaDomain.trim().isEmpty) {
      throw ArgumentError('Okta domain must not be empty.');
    }
    if (clientId.trim().isEmpty) {
      throw ArgumentError('Client ID must not be empty.');
    }
  }

  /// Constructs an IdP-initiated SSO URL with customizable parameters.
  ///
  /// The URL follows Okta's IdP-initiated SSO format and includes required
  /// parameters like RelayState. The [customizeParams] callback allows for
  /// dynamic parameter customization.
  ///
  /// Example:
  /// ```dart
  /// final sso = AortemOktaIdpInitiatedSSO(
  ///   oktaDomain: 'your-org.okta.com',
  ///   clientId: '0oa1a2b3c4d5e6f7g8h9',
  ///   defaultRelayState: '/dashboard',
  /// );
  ///
  /// final ssoUrl = sso.initiateIdpSso((params) {
  ///   params['RelayState'] = '/custom-landing'; // Override default
  ///   params['login_hint'] = 'user@example.com';
  /// });
  /// ```
  ///
  /// @param customizeParams Callback to modify SSO parameters
  /// @return String The fully constructed SSO URL
  /// @throws ArgumentError If required parameters are missing
  /// @throws Exception If URL construction fails or parameters are invalid
  String initiateIdpSso(void Function(Map<String, String>) customizeParams) {
    final params = <String, String>{};

    // Add default RelayState if available
    if (defaultRelayState != null && defaultRelayState!.trim().isNotEmpty) {
      params['RelayState'] = defaultRelayState!;
    }

    // Allow consumer to override or extend parameters
    try {
      customizeParams(params);
    } catch (e) {
      throw Exception('Error customizing IdP SSO parameters: $e');
    }

    // Validate required parameters
    if (!params.containsKey('RelayState') ||
        params['RelayState']!.trim().isEmpty) {
      throw ArgumentError('Missing required parameter: RelayState');
    }

    // Construct the base URL
    final baseUrl = Uri.https(oktaDomain, '/sso/idps/$clientId');

    // Add query parameters
    final ssoUrl = baseUrl.replace(queryParameters: params);

    if (!ssoUrl.hasScheme || !ssoUrl.host.contains('.')) {
      throw Exception('Constructed SSO URL is invalid: $ssoUrl');
    }

    return ssoUrl.toString();
  }
}
