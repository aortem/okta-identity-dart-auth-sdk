/// Enables Identity Provider (IdP)-Initiated Single Sign-On (SSO) for OktaIdentity.
///
/// This class constructs secure redirect URLs for IdP-initiated SSO flows,
/// allowing OktaIdentity (the Identity Provider) to initiate authentication without
/// requiring a service provider request first.
///
/// Features:
/// - Constructs properly formatted IdP-initiated SSO URLs
/// - Validates required parameters
/// - Supports dynamic parameter customization
/// - Handles both default and custom RelayState values
class OktaIdentityIdpInitiatedSSO {
  /// The base domain of the OktaIdentity organization (e.g., 'your-org.okta.com')
  final String oktaIdentityDomain;

  /// The client ID of the OktaIdentity OAuth application
  final String clientId;

  /// Optional default RelayState value for SSO redirects
  final String? defaultRelayState;

  /// Creates an instance of [OktaIdentityIdpInitiatedSSO].
  ///
  /// Required parameters:
  /// - [oktaIdentityDomain]: The base domain of your OktaIdentity organization
  /// - [clientId]: The client ID of your OktaIdentity application
  ///
  /// Optional parameters:
  /// - [defaultRelayState]: Default RelayState value for SSO redirects
  ///
  /// Throws [ArgumentError] if required parameters are empty
  OktaIdentityIdpInitiatedSSO({
    required this.oktaIdentityDomain,
    required this.clientId,
    this.defaultRelayState,
  }) {
    if (oktaIdentityDomain.trim().isEmpty) {
      throw ArgumentError('OktaIdentity domain must not be empty.');
    }
    if (clientId.trim().isEmpty) {
      throw ArgumentError('Client ID must not be empty.');
    }
  }

  /// Constructs an IdP-initiated SSO URL with customizable parameters.
  ///
  /// The URL follows OktaIdentity's IdP-initiated SSO format and includes required
  /// parameters like RelayState. The [customizeParams] callback allows for
  /// dynamic parameter customization.
  ///
  /// Example:
  /// ```dart
  /// final sso = OktaIdentityIdpInitiatedSSO(
  ///   oktaIdentityDomain: 'your-org.okta.com',
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
    final baseUrl = Uri.https(oktaIdentityDomain, '/sso/idps/$clientId');

    // Add query parameters
    final ssoUrl = baseUrl.replace(queryParameters: params);

    if (!ssoUrl.hasScheme || !ssoUrl.host.contains('.')) {
      throw Exception('Constructed SSO URL is invalid: $ssoUrl');
    }

    return ssoUrl.toString();
  }
}
