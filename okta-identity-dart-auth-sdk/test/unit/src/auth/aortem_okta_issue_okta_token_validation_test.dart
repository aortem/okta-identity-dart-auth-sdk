import 'dart:convert';
import 'dart:core';
import 'package:ds_tools_testing/ds_tools_testing.dart';

import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_token_validation.dart';
import 'package:okta_identity_dart_auth_sdk/src/exception/aortem_okta_issue_token_validation_token.dart';

void main() {
  group('AortemOktaTokenValidator', () {
    late AortemOktaTokenValidator validator;
    late String fakeToken;

    setUp(() {
      validator = AortemOktaTokenValidator(
        oktaDomain: 'example.okta.com',
        clientId: 'test-client-id',
      );

      // NOTE: This token is just base64-encoded dummy data (won't actually verify)
      final header = base64Url
          .encode(utf8.encode(jsonEncode({'alg': 'RS256', 'kid': 'test-key'})));
      final payload = base64Url.encode(utf8.encode(jsonEncode({
        'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/
            1000,
        'iss': 'https://example.okta.com/oauth2/default',
        'aud': 'test-client-id',
      })));
      final signature = base64Url.encode(List.generate(64, (_) => 1)); // fake

      fakeToken = '$header.$payload.$signature';
    });

    test('throws on empty token', () async {
      expect(() => validator.validateToken(''), throwsArgumentError);
    });

    test('throws on malformed token', () async {
      expect(() => validator.validateToken('invalid.token'),
          throwsA(isA<TokenValidationException>()));
    });

    test('throws when kid is missing', () async {
      final badHeader =
          base64Url.encode(utf8.encode(jsonEncode({'alg': 'RS256'})));
      final payload = base64Url.encode(
          utf8.encode(jsonEncode({'exp': 9999999999, 'aud': 'x', 'iss': 'x'})));
      final signature = base64Url.encode(List.generate(64, (_) => 1));
      final badToken = '$badHeader.$payload.$signature';

      expect(() => validator.validateToken(badToken),
          throwsA(isA<TokenValidationException>()));
    });

    test('throws when key is not found in JWKS', () async {
      final validator = AortemOktaTokenValidator(
        oktaDomain: 'example.okta.com',
        clientId: 'test-client-id',
      );

      expect(() => validator.validateToken(fakeToken),
          throwsA(isA<TokenValidationException>()));
    });

    // NOTE: A full success test would require mocking _verifySignature
    // which is async and uses crypto internals.
  });
}
