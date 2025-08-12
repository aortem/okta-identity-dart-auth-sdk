import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_saml_logout.dart';

void main() {
  group('OktaSamlLogoutConsumer', () {
    const oktaDomain = 'https://example.okta.com';
    const applicationId = 'abc123';
    const defaultRelayState = 'https://myapp.com/logout/callback';

    late OktaSamlLogoutConsumer consumer;

    setUp(() {
      consumer = OktaSamlLogoutConsumer(
        oktaDomain: oktaDomain,
        applicationId: applicationId,
        defaultRelayState: defaultRelayState,
      );
    });

    test('constructs logout URL with required parameters', () async {
      final url = await consumer.logout((payload) {
        payload['SAMLRequest'] = 'mockSAMLRequestData';
      });

      expect(url, contains('SAMLRequest=mockSAMLRequestData'));
      expect(url, contains(Uri.encodeComponent(applicationId)));
      expect(
        url,
        contains('RelayState=${Uri.encodeComponent(defaultRelayState)}'),
      );
    });

    test('throws ArgumentError when SAMLRequest is missing', () async {
      expect(
        () => consumer.logout((payload) {}),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message == 'SAMLRequest is required in the logout payload.',
          ),
        ),
      );
    });

    test('throws ArgumentError if oktaDomain is empty', () {
      expect(
        () => OktaSamlLogoutConsumer(
          oktaDomain: '',
          applicationId: applicationId,
          defaultRelayState: defaultRelayState,
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError if applicationId is empty', () {
      expect(
        () => OktaSamlLogoutConsumer(
          oktaDomain: oktaDomain,
          applicationId: '',
          defaultRelayState: defaultRelayState,
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError if defaultRelayState is empty', () {
      expect(
        () => OktaSamlLogoutConsumer(
          oktaDomain: oktaDomain,
          applicationId: applicationId,
          defaultRelayState: '',
        ),
        throwsArgumentError,
      );
    });

    test('supports async consumer callback', () async {
      final url = await consumer.logout((payload) async {
        await Future.delayed(Duration(milliseconds: 10));
        payload['SAMLRequest'] = 'asyncSAMLRequest';
      });

      expect(url, contains('SAMLRequest=asyncSAMLRequest'));
    });
  });
}
