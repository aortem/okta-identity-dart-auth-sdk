import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/user/okta_issue_okta_authenticator_management.dart';

void main() {
  const oktaIdentityDomain = 'test.okta.com';
  const apiToken = 'fake-token';
  const userId = 'user123';
  const factorId = 'factorABC';

  group('OktaIdentityAuthenticatorManagement', () {
    test('addAuthenticator - success', () async {
      final mockClient = MockClient((http.Request request) async {
        expect(
          request.url.toString(),
          'https://$oktaIdentityDomain/api/v1/users/$userId/factors',
        );
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'SSWS $apiToken');
        return http.Response(jsonEncode({'id': 'factor123'}), 200);
      });

      final manager = OktaIdentityAuthenticatorManagement(
        oktaIdentityDomain: oktaIdentityDomain,
        apiToken: apiToken,
        httpClient: mockClient,
      );

      final result = await manager.addAuthenticator(
        userId: userId,
        payloadBuilder: () => {
          'authenticatorType': 'sms',
          'profile': {'phoneNumber': '+15556667777'},
        },
      );

      expect(result, containsPair('id', 'factor123'));
    });

    test('listAuthenticators - success', () async {
      final mockResponse = [
        {'id': 'factor1', 'type': 'sms'},
        {'id': 'factor2', 'type': 'email'},
      ];

      final mockClient = MockClient((http.Request request) async {
        expect(
          request.url.toString(),
          'https://$oktaIdentityDomain/api/v1/users/$userId/factors',
        );
        expect(request.method, 'GET');
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final manager = OktaIdentityAuthenticatorManagement(
        oktaIdentityDomain: oktaIdentityDomain,
        apiToken: apiToken,
        httpClient: mockClient,
      );

      final result = await manager.listAuthenticators(userId: userId);

      expect(result.length, 2);
      expect(result[0]['id'], 'factor1');
    });

    test('deleteAuthenticator - success', () async {
      final mockClient = MockClient((http.Request request) async {
        expect(
          request.url.toString(),
          'https://$oktaIdentityDomain/api/v1/users/$userId/factors/$factorId',
        );
        expect(request.method, 'DELETE');
        return http.Response('', 204);
      });

      final manager = OktaIdentityAuthenticatorManagement(
        oktaIdentityDomain: oktaIdentityDomain,
        apiToken: apiToken,
        httpClient: mockClient,
      );

      await manager.deleteAuthenticator(userId: userId, factorId: factorId);
    });

    test(
      'addAuthenticator - missing authenticatorType throws ArgumentError',
      () async {
        final manager = OktaIdentityAuthenticatorManagement(
          oktaIdentityDomain: oktaIdentityDomain,
          apiToken: apiToken,
          httpClient: MockClient((_) async => http.Response('', 200)),
        );

        expect(
          () => manager.addAuthenticator(
            userId: userId,
            payloadBuilder: () => {'profile': {}}, // Missing authenticatorType
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'listAuthenticators - invalid response format throws Exception',
      () async {
        final mockClient = MockClient((http.Request request) async {
          return http.Response(jsonEncode({'not': 'a list'}), 200);
        });

        final manager = OktaIdentityAuthenticatorManagement(
          oktaIdentityDomain: oktaIdentityDomain,
          apiToken: apiToken,
          httpClient: mockClient,
        );

        expect(
          () => manager.listAuthenticators(userId: userId),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'deleteAuthenticator - missing factorId throws ArgumentError',
      () async {
        final manager = OktaIdentityAuthenticatorManagement(
          oktaIdentityDomain: oktaIdentityDomain,
          apiToken: apiToken,
          httpClient: MockClient((_) async => http.Response('', 204)),
        );

        expect(
          () => manager.deleteAuthenticator(userId: userId, factorId: ''),
          throwsA(isA<ArgumentError>()),
        );
      },
    );
  });
}
