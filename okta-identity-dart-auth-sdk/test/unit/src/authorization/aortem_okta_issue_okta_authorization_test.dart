import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/authorization/okta_issue_okta_authorization.dart';

import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('OktaIdentityAuthorization', () {
    const oktaIdentityDomain = 'example.okta.com';
    const clientId = 'test-client-id';
    const redirectUri = 'https://myapp.com/callback';

    test('constructs correct authorization URL', () {
      final auth = OktaIdentityAuthorization(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        redirectUri: redirectUri,
      );

      final url = auth.authorizeApplication((params) {
        params['response_type'] = 'code';
        params['scope'] = 'openid email';
        params['state'] = 'abc123';
      });

      expect(
        url.toString(),
        contains('https://$oktaIdentityDomain/oauth2/v1/authorize'),
      );
      expect(url.queryParameters['client_id'], equals(clientId));
      expect(url.queryParameters['redirect_uri'], equals(redirectUri));
      expect(url.queryParameters['response_type'], equals('code'));
      expect(url.queryParameters['scope'], equals('openid email'));
      expect(url.queryParameters['state'], equals('abc123'));
    });

    test(
      'throws ArgumentError if required fields are missing in URL construction',
      () {
        final auth = OktaIdentityAuthorization(
          oktaIdentityDomain: oktaIdentityDomain,
          clientId: clientId,
          redirectUri: redirectUri,
        );

        expect(
          () => auth.authorizeApplication((params) {
            params.remove('client_id');
          }),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('successfully exchanges authorization code for tokens', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/token'));
        expect(request.method, equals('POST'));

        final body = request.bodyFields;
        expect(body['code'], equals('valid-code'));
        expect(body['client_id'], equals(clientId));
        expect(body['redirect_uri'], equals(redirectUri));

        return http.Response(
          jsonEncode({
            'access_token': 'abc123',
            'id_token': 'xyz456',
            'token_type': 'Bearer',
          }),
          200,
        );
      });

      final auth = OktaIdentityAuthorization(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        redirectUri: redirectUri,
        httpClient: mockClient,
      );

      final tokens = await auth.authorizeEndpoint((params) {
        params['code'] = 'valid-code';
      });

      expect(tokens['access_token'], equals('abc123'));
      expect(tokens['id_token'], equals('xyz456'));
      expect(tokens['token_type'], equals('Bearer'));
    });

    test('throws error when token exchange fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Invalid request', 400);
      });

      final auth = OktaIdentityAuthorization(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        redirectUri: redirectUri,
        httpClient: mockClient,
      );

      expect(
        () => auth.authorizeEndpoint((params) {
          params['code'] = 'invalid-code';
        }),
        throwsA(isA<Exception>()),
      );
    });
  });
}
