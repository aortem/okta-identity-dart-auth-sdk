import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart' as http show MockClient;

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() {
  group('OktaIdentitySocialLoginConsumer', () {
    const oktaIdentityDomain = 'https://your-org.okta.com';
    const clientId = 'test-client-id';
    const redirectUri = 'com.example.app:/callback';

    late OktaIdentitySocialLoginConsumer consumer;

    test(
      'should throw ArgumentError when required fields are missing',
      () async {
        consumer = OktaIdentitySocialLoginConsumer(
          oktaIdentityDomain: oktaIdentityDomain,
          clientId: clientId,
          redirectUri: redirectUri,
          httpClient: http.MockClient((_) async => http.Response('{}', 400)),
        );

        expect(
          () => consumer.signIn((payload) async {
            // Missing provider and social_token
          }),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('should throw Exception on failed response', () async {
      final mockClient = http.MockClient((_) async {
        return http.Response('Unauthorized', 401);
      });

      consumer = OktaIdentitySocialLoginConsumer(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        redirectUri: redirectUri,
        httpClient: mockClient,
      );

      expect(
        () => consumer.signIn((payload) async {
          payload['provider'] = 'facebook';
          payload['social_token'] = 'invalid_token';
        }),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'Failed to authenticate with social provider',
                ),
          ),
        ),
      );
    });
  });
}
