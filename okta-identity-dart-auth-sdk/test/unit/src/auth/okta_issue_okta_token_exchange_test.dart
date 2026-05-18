import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'dart:convert';

import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() {
  group('OktaIdentityTokenExchangeConsumer', () {
    test('should successfully exchange token for authorization code', () async {
      final mockResponse = json.encode({
        'access_token': 'mockAccessToken',
        'id_token': 'mockIdToken',
        'refresh_token': 'mockRefreshToken',
      });

      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://example.okta.com/oauth2/default/v1/token',
        );
        expect(request.method, equals('POST'));
        expect(request.bodyFields['client_id'], equals('testClientId'));
        expect(
          request.bodyFields['redirect_uri'],
          equals('https://example.com/callback'),
        );
        expect(request.bodyFields['grant_type'], equals('authorization_code'));
        expect(request.bodyFields['code'], equals('mockAuthorizationCode'));
        return http.Response(mockResponse, 200);
      });

      final tokenExchangeConsumer = OktaIdentityTokenExchangeConsumer(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://example.com/callback',
        httpClient: mockClient,
      );

      // Prepare the consumer callback
      final modifyPayload = (Map<String, String> payload) {
        payload['grant_type'] = 'authorization_code';
        payload['code'] = 'mockAuthorizationCode';
      };

      final response = await tokenExchangeConsumer.exchangeToken(
        modifyPayload: modifyPayload,
      );

      // Verify the expected result
      expect(response['access_token'], 'mockAccessToken');
      expect(response['id_token'], 'mockIdToken');
      expect(response['refresh_token'], 'mockRefreshToken');
    });

    test('should throw ArgumentError if grant_type is missing', () async {
      final tokenExchangeConsumer = OktaIdentityTokenExchangeConsumer(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://example.com/callback',
      );

      final modifyPayload = (Map<String, String> payload) {
        // Don't set grant_type here to trigger an error
      };

      expect(
        () async => await tokenExchangeConsumer.exchangeToken(
          modifyPayload: modifyPayload,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'should throw ArgumentError if authorization code is missing',
      () async {
        final tokenExchangeConsumer = OktaIdentityTokenExchangeConsumer(
          oktaIdentityDomain: 'https://example.okta.com',
          clientId: 'testClientId',
          redirectUri: 'https://example.com/callback',
        );

        final modifyPayload = (Map<String, String> payload) {
          payload['grant_type'] = 'authorization_code'; // Missing the 'code'
        };

        expect(
          () async => await tokenExchangeConsumer.exchangeToken(
            modifyPayload: modifyPayload,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('should throw Exception if network request fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Network error', 500);
      });

      final tokenExchangeConsumer = OktaIdentityTokenExchangeConsumer(
        oktaIdentityDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://example.com/callback',
        httpClient: mockClient,
      );

      final modifyPayload = (Map<String, String> payload) {
        payload['grant_type'] = 'authorization_code';
        payload['code'] = 'mockAuthorizationCode';
      };

      expect(
        () async => await tokenExchangeConsumer.exchangeToken(
          modifyPayload: modifyPayload,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
