import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/sso/aortem_okta_issue_okta_idp_initiated_sso.dart';

void main() {
  group('OktaIdpInitiatedSSO', () {
    const oktaDomain = 'example.okta.com';
    const clientId = 'client123';
    const defaultRelayState = 'https://myapp.com/after-login';

    test('constructs SSO URL with default RelayState and custom params', () {
      final sso = OktaIdpInitiatedSSO(
        oktaDomain: oktaDomain,
        clientId: clientId,
        defaultRelayState: defaultRelayState,
      );

      final url = sso.initiateIdpSso((params) {
        params['utm_source'] = 'email_campaign';
        params['feature'] = 'login';
      });

      expect(url, contains(oktaDomain));
      expect(url, contains('RelayState=https%3A%2F%2Fmyapp.com%2Fafter-login'));
      expect(url, contains('utm_source=email_campaign'));
      expect(url, contains('feature=login'));
      expect(url, contains(clientId));
    });

    test('throws ArgumentError if RelayState is missing', () {
      final sso = OktaIdpInitiatedSSO(
        oktaDomain: oktaDomain,
        clientId: clientId,
      );

      expect(
        () => sso.initiateIdpSso((params) {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when oktaDomain is empty', () {
      expect(
        () => OktaIdpInitiatedSSO(oktaDomain: '', clientId: clientId),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when clientId is empty', () {
      expect(
        () => OktaIdpInitiatedSSO(oktaDomain: oktaDomain, clientId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws Exception if constructed URL is invalid', () {
      final sso = OktaIdpInitiatedSSO(
        oktaDomain: 'not-a-valid-domain',
        clientId: clientId,
        defaultRelayState: defaultRelayState,
      );

      expect(() => sso.initiateIdpSso((params) {}), throwsA(isA<Exception>()));
    });

    test('allows complete override of RelayState in consumer', () {
      final sso = OktaIdpInitiatedSSO(
        oktaDomain: oktaDomain,
        clientId: clientId,
        defaultRelayState: 'https://default.com/relay',
      );

      final url = sso.initiateIdpSso((params) {
        params['RelayState'] = 'https://override.com';
      });

      expect(url, contains('RelayState=https%3A%2F%2Foverride.com'));
      expect(url, isA<String>());
    });
  });
}
