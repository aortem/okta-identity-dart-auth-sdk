import 'dart:async';

/// A class to handle SAML 2.0 logout operations with Okta using a consumer pattern.
///
/// This class implements the SAML Single Logout (SLO) flow to properly log users out
/// of both the application and Okta session. It follows the SAML 2.0 Web Browser
/// Single Logout Profile.
///
/// The consumer pattern allows flexible configuration of the SAML logout request
/// while ensuring required parameters are present.
class OktaSamlLogoutConsumer {
  /// The base domain URL of the Okta organization
  /// (e.g., 'https://your-org.okta.com')
  final String oktaDomain;

  /// The ID of the SAML application in Okta
  final String applicationId;

  /// The default RelayState value to be included in logout requests
  final String defaultRelayState;

  /// Creates an instance of [OktaSamlLogoutConsumer].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base URL of your Okta organization (must not be empty)
  /// - [applicationId]: The ID of your SAML application in Okta (must not be empty)
  /// - [defaultRelayState]: The default RelayState value (must not be empty)
  ///
  /// Throws [ArgumentError] if any required parameters are empty.
  OktaSamlLogoutConsumer({
    required this.oktaDomain,
    required this.applicationId,
    required this.defaultRelayState,
  }) {
    if (oktaDomain.isEmpty) {
      throw ArgumentError('Okta domain is required.');
    }
    if (applicationId.isEmpty) {
      throw ArgumentError('SAML application ID is required.');
    }
    if (defaultRelayState.isEmpty) {
      throw ArgumentError('Default RelayState is required.');
    }
  }

  /// Initiates the SAML Single Logout (SLO) flow.
  ///
  /// The [payloadModifier] callback allows customization of the SAML logout parameters
  /// while ensuring required fields are present. The base payload includes:
  /// - RelayState: The default RelayState value
  ///
  /// The callback must provide:
  /// - SAMLRequest: A valid SAML logout request (base64 encoded)
  ///
  /// The callback may optionally provide:
  /// - Signature: A signature for the request
  /// - SigAlg: The signature algorithm used
  ///
  /// Example usage:
  /// ```dart
  /// final samlLogout = OktaSamlLogoutConsumer(
  ///   oktaDomain: 'https://your-org.okta.com',
  ///   applicationId: '0oa1a2b3c4d5e6f7g8h9',
  ///   defaultRelayState: 'https://yourapp.com/logout',
  /// );
  ///
  /// final logoutUrl = await samlLogout.logout((payload) async {
  ///   payload['SAMLRequest'] = generateSamlLogoutRequest();
  ///   // Optional: Add signature if required
  ///   payload['Signature'] = generateSignature();
  ///   payload['SigAlg'] = 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256';
  /// });
  /// ```
  ///
  /// Returns a [String] containing the complete logout URL that can be used for
  /// redirecting the user's browser to initiate logout.
  ///
  /// Throws [ArgumentError] if:
  /// - The SAMLRequest parameter is missing or empty
  /// - Any required parameters are invalid
  Future<String> logout(
    FutureOr<void> Function(Map<String, String> payload) payloadModifier,
  ) async {
    // Base payload with required SAML parameters
    final Map<String, String> payload = {'RelayState': defaultRelayState};

    // Allow consumer to modify the payload (sync or async)
    await Future.sync(() => payloadModifier(payload));

    // Validate required SAML parameters
    if (!payload.containsKey('SAMLRequest') ||
        payload['SAMLRequest']!.isEmpty) {
      throw ArgumentError('SAMLRequest is required in the logout payload.');
    }

    // Construct the query string with properly encoded parameters
    final queryString = payload.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    // Construct the full SAML logout URL
    final logoutUrl =
        '$oktaDomain/app/${Uri.encodeComponent(applicationId)}/slo/saml?$queryString';

    return logoutUrl;
  }
}
