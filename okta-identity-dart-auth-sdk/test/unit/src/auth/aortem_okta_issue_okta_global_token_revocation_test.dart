import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart';

import 'package:okta_identity_dart_auth_sdk/src/auth/okta_issue_okta_global_token_revocation.dart';
import 'package:okta_identity_dart_auth_sdk/src/exception/okta_issue_missing_token_exception.dart';
import 'package:okta_identity_dart_auth_sdk/src/exception/okta_issue_revocation_exception.dart';

void main() {
  group('OktaIdentityGlobalTokenRevocationConsumer', () {
    test('successfully revokes token', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/v1/revoke'));
        expect(request.method, equals('POST'));
        expect(request.headers['Authorization'], contains('Basic'));
        expect(request.bodyFields['token'], equals('abc123'));
        return http.Response('', 200);
      });

      final consumer = OktaIdentityGlobalTokenRevocationConsumer(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'clientId',
        clientSecret: 'clientSecret',
        httpClient: mockClient,
      );

      await consumer.revokeToken(
        buildPayload: (builder) {
          builder.setToken('abc123');
        },
      );
    });

    test('throws MissingTokenFieldException when token is missing', () async {
      final consumer = OktaIdentityGlobalTokenRevocationConsumer(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'clientId',
        clientSecret: 'clientSecret',
        httpClient: MockClient((_) async => http.Response('', 200)),
      );

      expect(
        () async => await consumer.revokeToken(buildPayload: (_) {}),
        throwsA(isA<MissingTokenFieldException>()),
      );
    });

    test('throws OktaIdentityRevocationException on HTTP error', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Unauthorized', 401),
      );

      final consumer = OktaIdentityGlobalTokenRevocationConsumer(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'clientId',
        clientSecret: 'clientSecret',
        httpClient: mockClient,
      );

      expect(
        () async => await consumer.revokeToken(
          buildPayload: (builder) {
            builder.setToken('abc123');
          },
        ),
        throwsA(isA<OktaIdentityRevocationException>()),
      );
    });
  });
}
