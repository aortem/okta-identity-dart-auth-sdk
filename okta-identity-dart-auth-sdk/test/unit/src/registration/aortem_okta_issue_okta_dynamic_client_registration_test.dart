import 'dart:convert';
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/registration/aortem_okta_issue_okta_dynamic_client_registration.dart';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:http/testing.dart';
// Update import path if needed

void main() {
  group('AortemOktaDynamicClientRegistration', () {
    late List<http.Request> capturedRequests;

    setUp(() {
      capturedRequests = [];
    });

    test('registerClient returns credentials on successful registration',
        () async {
      final mockClient = MockClient((http.Request request) async {
        capturedRequests.add(request);

        expect(request.method, equals('POST'));
        expect(request.url.toString(), contains('/oauth2/v1/clients'));

        final body = jsonDecode(request.body);
        expect(body['redirect_uris'], contains('https://myapp.dev/callback'));
        expect(body['application_type'], equals('web'));

        return http.Response(
            jsonEncode({
              'client_id': 'abc123',
              'client_secret': 'secret456',
              'token_endpoint_auth_method': 'client_secret_basic',
            }),
            201);
      });

      final registration = AortemOktaDynamicClientRegistration(
        oktaDomain: 'example.okta.com',
        httpClient: mockClient,
      );

      final response = await registration.registerClient((payload) {
        payload['redirect_uris'] = ['https://myapp.dev/callback'];
      });

      expect(response['client_id'], equals('abc123'));
      expect(response['client_secret'], equals('secret456'));
    });

    test('throws ArgumentError if redirect_uris is missing', () async {
      final registration = AortemOktaDynamicClientRegistration(
        oktaDomain: 'example.okta.com',
        httpClient: MockClient((_) async => http.Response('{}', 201)),
      );

      expect(
        () => registration.registerClient((payload) {
          // Intentionally leave out redirect_uris
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws Exception on non-201 response from Okta', () async {
      final mockClient = MockClient((http.Request request) async {
        return http.Response('Bad Request', 400);
      });

      final registration = AortemOktaDynamicClientRegistration(
        oktaDomain: 'example.okta.com',
        httpClient: mockClient,
      );

      expect(
        () => registration.registerClient((payload) {
          payload['redirect_uris'] = ['https://myapp.dev/callback'];
        }),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Client registration failed'))),
      );
    });

    test('throws Exception on network error', () async {
      final mockClient = MockClient((_) async {
        throw Exception('Connection refused');
      });

      final registration = AortemOktaDynamicClientRegistration(
        oktaDomain: 'example.okta.com',
        httpClient: mockClient,
      );

      expect(
        () => registration.registerClient((payload) {
          payload['redirect_uris'] = ['https://myapp.dev/callback'];
        }),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Dynamic client registration failed'))),
      );
    });
  });
}
