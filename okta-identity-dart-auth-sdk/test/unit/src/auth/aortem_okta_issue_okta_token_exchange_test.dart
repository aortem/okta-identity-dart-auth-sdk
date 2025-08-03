import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'dart:convert';

import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_token_exchange.dart';

// Mock class for the HTTP client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('AortemOktaTokenExchangeConsumer', () {
    late AortemOktaTokenExchangeConsumer tokenExchangeConsumer;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      tokenExchangeConsumer = AortemOktaTokenExchangeConsumer(
        oktaDomain: 'https://example.okta.com',
        clientId: 'testClientId',
        redirectUri: 'https://example.com/callback',
      );
    });

    test('should successfully exchange token for authorization code', () async {
      // Prepare the mock response
      final mockResponse = json.encode({
        'access_token': 'mockAccessToken',
        'id_token': 'mockIdToken',
        'refresh_token': 'mockRefreshToken',
      });

      when(
        mockHttpClient.post(
          Uri.parse('https://example.okta.com/oauth2/default/v1/token'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

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
      when(
        mockHttpClient.post(
          Uri.parse('https://example.okta.com/oauth2/default/v1/token'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Network error', 500));

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
