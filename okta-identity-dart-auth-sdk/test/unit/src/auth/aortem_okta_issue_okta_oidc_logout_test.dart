import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_oidc_logout.dart';

import 'package:ds_standard_features/ds_standard_features.dart' as http;

class FakeHttpClient extends http.BaseClient {
  final int statusCode;
  final String body;

  FakeHttpClient({this.statusCode = 302, this.body = 'Redirecting...'});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stream = http.ByteStream.fromBytes(body.codeUnits);
    return http.StreamedResponse(stream, statusCode);
  }
}

void main() {
  const oktaIdentityDomain = 'https://fake.okta.com';
  const clientId = 'fake-client-id';
  const redirectUri = 'fake:/logout';

  group('OktaIdentityOidcLogoutConsumer', () {
    test('returns logout Uri successfully', () async {
      final consumer = OktaIdentityOidcLogoutConsumer(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        postLogoutRedirectUri: redirectUri,
        httpClient: FakeHttpClient(), // Simulated success response
      );

      final logoutUri = await consumer.logout(
        modify: (payload) {
          // You could also add id_token_hint here
          payload['custom'] = 'value';
        },
      );

      expect(logoutUri.toString(), contains('logout'));
      expect(logoutUri.queryParameters['client_id'], equals(clientId));
      expect(
        logoutUri.queryParameters['post_logout_redirect_uri'],
        equals(redirectUri),
      );
      expect(logoutUri.queryParameters['custom'], equals('value'));
    });

    test('throws ArgumentError if required fields are missing', () async {
      final consumer = OktaIdentityOidcLogoutConsumer(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        postLogoutRedirectUri: redirectUri,
        httpClient: FakeHttpClient(),
      );

      expect(
        () => consumer.logout(
          modify: (payload) {
            payload.remove('client_id');
          },
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws Exception on HTTP failure response', () async {
      final consumer = OktaIdentityOidcLogoutConsumer(
        oktaIdentityDomain: oktaIdentityDomain,
        clientId: clientId,
        postLogoutRedirectUri: redirectUri,
        httpClient: FakeHttpClient(
          statusCode: 500,
          body: 'Internal Server Error',
        ),
      );

      expect(() => consumer.logout(modify: (_) {}), throwsA(isA<Exception>()));
    });
  });
}
