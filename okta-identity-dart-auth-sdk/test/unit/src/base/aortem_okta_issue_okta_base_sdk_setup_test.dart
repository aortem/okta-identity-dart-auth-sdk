// File: test/base/aortem_okta_issue_okta_base_sdk_setup_test.dart

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/base/aortem_okta_issue_okta_base_sdk_setup.dart';

void main() {
  group('AortemOktaBaseSDK', () {
    test('initializes with valid configuration', () {
      final config = AortemOktaConfig(
        oktaDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://myapp.com/callback',
      );

      final sdk = AortemOktaBaseSDK(config: config);

      expect(sdk.config.oktaDomain, equals('https://example.okta.com'));
      expect(sdk.httpClient, isA<http.Client>());

      sdk.dispose(); // clean up
    });

    test('throws ArgumentError for empty config values', () {
      expect(
        () => AortemOktaConfig(oktaDomain: '', clientId: '', redirectUri: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('uses provided HTTP client', () {
      final mockClient = http.Client();
      final config = AortemOktaConfig(
        oktaDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://myapp.com/callback',
      );

      final sdk = AortemOktaBaseSDK(config: config, httpClient: mockClient);
      expect(sdk.httpClient, equals(mockClient));

      sdk.dispose();
    });
  });
}
