import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() {
  group('OktaIdentityMetadata', () {
    const oktaIdentityDomain = 'example.okta.com';
    const metadataUrl =
        'https://example.okta.com/.well-known/openid-configuration';

    final mockResponse = {
      'issuer': 'https://example.okta.com',
      'authorization_endpoint': 'https://example.okta.com/oauth2/v1/authorize',
      'token_endpoint': 'https://example.okta.com/oauth2/v1/token',
      'jwks_uri': 'https://example.okta.com/oauth2/v1/keys',
    };

    test('fetches and caches metadata successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), metadataUrl);
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final metadata = OktaIdentityMetadata(
        oktaIdentityDomain: oktaIdentityDomain,
        httpClient: mockClient,
      );

      final result = await metadata.getMetadata();
      expect(result['issuer'], equals(mockResponse['issuer']));
      expect(
        result['authorization_endpoint'],
        equals(mockResponse['authorization_endpoint']),
      );

      // Verify cache works: second call shouldn't trigger new HTTP call
      final cached = await metadata.getMetadata();
      expect(cached, same(result)); // should be same map object
    });

    test('throws exception on non-200 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final metadata = OktaIdentityMetadata(
        oktaIdentityDomain: oktaIdentityDomain,
        httpClient: mockClient,
      );

      expect(
        () async => await metadata.getMetadata(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception on invalid JSON format', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not JSON', 200);
      });

      final metadata = OktaIdentityMetadata(
        oktaIdentityDomain: oktaIdentityDomain,
        httpClient: mockClient,
      );

      expect(
        () async => await metadata.getMetadata(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception when required fields are missing', () async {
      final incompleteResponse = {
        'issuer': 'https://example.okta.com',
        // Missing `authorization_endpoint`, etc.
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(incompleteResponse), 200);
      });

      final metadata = OktaIdentityMetadata(
        oktaIdentityDomain: oktaIdentityDomain,
        httpClient: mockClient,
      );

      expect(
        () async => await metadata.getMetadata(),
        throwsA(isA<Exception>()),
      );
    });

    test('uses cache until invalidated manually', () async {
      int callCount = 0;

      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final metadata = OktaIdentityMetadata(
        oktaIdentityDomain: oktaIdentityDomain,
        httpClient: mockClient,
      );

      await metadata.getMetadata();
      await metadata.getMetadata(); // uses cache
      expect(callCount, equals(1));

      metadata.invalidateCache();
      await metadata.getMetadata(); // refetches
      expect(callCount, equals(2));
    });
  });
}
