import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() {
  group('OktaIdentityTokenRevocation', () {
    const oktaIdentityDomain = 'dev-123456.okta.com';
    const clientId = 'test-client-id';
    const clientSecret = 'test-secret';
    const testToken = 'dummy-token';

    test('revokeToken succeeds with status 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('https://$oktaIdentityDomain/oauth2/default/v1/revoke'),
        );
        expect(
          request.headers['Authorization'],
          startsWith('Basic '),
        ); // Check Basic auth
        expect(request.bodyFields['token'], equals(testToken));
        return http.Response('', 200);
      });

      final revoker = OktaIdentityTokenRevocation(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        clientSecret: clientSecret,
        httpClient: mockClient,
      );

      await revoker.revokeToken(token: testToken);
    });

    test('throws ArgumentError for empty token', () {
      final revoker = OktaIdentityTokenRevocation(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        clientSecret: clientSecret,
      );

      expect(
        () => revoker.revokeToken(token: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws Exception on non-200 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final revoker = OktaIdentityTokenRevocation(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        clientSecret: clientSecret,
        httpClient: mockClient,
      );

      expect(
        () => revoker.revokeToken(token: testToken),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Failed to revoke token'),
          ),
        ),
      );
    });

    test('adds token_type_hint if provided', () async {
      final mockClient = MockClient((request) async {
        expect(request.bodyFields['token_type_hint'], equals('refresh_token'));
        return http.Response('', 200);
      });

      final revoker = OktaIdentityTokenRevocation(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        clientSecret: clientSecret,
        httpClient: mockClient,
      );

      await revoker.revokeToken(
        token: testToken,
        tokenTypeHint: 'refresh_token',
      );
    });
  });
}
