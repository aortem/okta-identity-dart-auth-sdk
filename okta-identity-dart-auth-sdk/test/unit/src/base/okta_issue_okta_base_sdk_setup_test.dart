// File: test/base/okta_issue_okta_base_sdk_setup_test.dart

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() {
  group('OktaIdentityBaseSDK', () {
    test('initializes with valid configuration', () {
      final config = OktaIdentityConfig(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://myapp.com/callback',
      );

      final sdk = OktaIdentityBaseSDK(config: config);

      expect(sdk.config.oktaIdentityDomain, equals('https://example.okta.com'));
      expect(sdk.httpClient, isA<http.Client>());

      sdk.dispose(); // clean up
    });

    test('throws ArgumentError for empty config values', () {
      expect(
        () => OktaIdentityConfig(
          oktaIdentityDomain: '',
          clientId: '',
          redirectUri: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('uses provided HTTP client', () {
      final mockClient = http.Client();
      final config = OktaIdentityConfig(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://myapp.com/callback',
      );

      final sdk = OktaIdentityBaseSDK(config: config, httpClient: mockClient);
      expect(sdk.httpClient, equals(mockClient));

      sdk.dispose();
    });
  });
}
