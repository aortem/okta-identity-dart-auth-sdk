import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart' as http show MockClient;
import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_social_login.dart';

import 'package:ds_standard_features/ds_standard_features.dart' as http;

void main() {
  group('OktaSocialLoginConsumer', () {
    const oktaDomain = 'https://your-org.okta.com';
    const clientId = 'test-client-id';
    const redirectUri = 'com.example.app:/callback';

    late OktaSocialLoginConsumer consumer;

    test(
      'should throw ArgumentError when required fields are missing',
      () async {
        consumer = OktaSocialLoginConsumer(
          oktaDomain: oktaDomain,
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

      consumer = OktaSocialLoginConsumer(
        oktaDomain: oktaDomain,
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
