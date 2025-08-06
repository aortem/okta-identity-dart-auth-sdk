import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:jwt_generator/jwt_generator.dart';
import '../exception/aortem_okta_issue_token_validation_token.dart';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// Validates JWT tokens issued by Okta using OAuth 2.0.
///
/// This class handles the validation of JWT tokens including:
/// - Signature verification using Okta's public keys
/// - Standard JWT claims validation (expiration, issuer, audience)
/// - Key rotation support through JWKS endpoint
class AortemOktaTokenValidator {
  /// The Okta domain (e.g., 'your-org.okta.com').
  final String oktaDomain;

  /// The client ID that should match the token's audience claim.
  final String clientId;

  /// The issuer URL derived from [oktaDomain].
  final String issuer;

  /// Cache for storing public keys by key ID (kid).
  final Map<String, Map<String, dynamic>> _cachedKeys = {};

  /// Creates an instance of [AortemOktaTokenValidator].
  ///
  /// Requires:
  /// - [oktaDomain]: Your Okta domain (e.g., 'your-org.okta.com')
  /// - [clientId]: The client ID that should match the token's audience claim
  AortemOktaTokenValidator({required this.oktaDomain, required this.clientId})
    : issuer = 'https://$oktaDomain/oauth2/default';

  /// Validates a JWT token and returns its decoded payload if valid.
  ///
  /// Performs the following validations:
  /// 1. Token structure (3 parts separated by dots)
  /// 2. Signature verification using Okta's public keys
  /// 3. Standard claims validation (expiration, issuer, audience)
  ///
  /// Throws [TokenValidationException] if validation fails.
  ///
  /// Returns the decoded payload if validation succeeds.
  Future<Map<String, dynamic>> validateToken(String token) async {
    if (token.isEmpty) throw ArgumentError('Token must not be empty');

    final parts = token.split('.');
    if (parts.length != 3) {
      throw TokenValidationException('Malformed JWT: Must have 3 parts');
    }

    final header = _decodeBase64Json(parts[0]);
    final payload = _decodeBase64Json(parts[1]);
    final signature = parts[2];

    final kid = header['kid'];
    if (kid == null)
      throw TokenValidationException('Missing "kid" in JWT header');

    // final publicKey = await _getPublicKey(kid);
    final publicKeyJwk = await _getPublicKey(kid);
    final pem = _jwkToPem(publicKeyJwk);
    final parser = RsaKeyParser();
    final rsaPublicKey = parser.extractPublicKey(pem);
    final rsaVerifier = RsaSignatureVerifier(publicKey: rsaPublicKey);
    final signedData = '${parts[0]}.${parts[1]}';

    final isValid = rsaVerifier.verify(signedData, signature);
    if (!isValid) {
      throw TokenValidationException('Invalid token signature');
    }

    _validateClaims(payload);
    return payload;
  }

  /// Decodes a base64 URL-safe encoded string and parses it as JSON.
  Map<String, dynamic> _decodeBase64Json(String input) {
    return jsonDecode(utf8.decode(_decodeBase64(input)));
  }

  /// Decodes a base64 URL-safe encoded string.
  Uint8List _decodeBase64(String input) {
    final normalized = base64Url.normalize(input);
    return base64Url.decode(normalized);
  }

  /// Fetches and caches public keys (JWKS) from Okta's JWKS endpoint.
  ///
  /// If the key is already cached, returns the cached version.
  /// Otherwise fetches the latest keys from Okta and caches them.
  ///
  /// Throws [TokenValidationException] if the key is not found.
  Future<Map<String, dynamic>> _getPublicKey(String kid) async {
    if (_cachedKeys.containsKey(kid)) {
      return _cachedKeys[kid]!;
    }

    final url = Uri.parse('https://$oktaDomain/oauth2/default/v1/keys');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw TokenValidationException(
        'Failed to retrieve JWKS: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);
    final keys = json['keys'] as List;

    for (final key in keys) {
      if (key['kid'] == kid) {
        _cachedKeys[kid] = key;
        return key;
      }
    }

    throw TokenValidationException('Public key not found for kid: $kid');
  }

  /// Converts a JSON Web Key (JWK) to a Dart RSA public key.
  // SimplePublicKey _jwkToPublicKey(Map<String, dynamic> jwk) {
  //   final n = _decodeBase64(jwk['n']);
  //   return SimplePublicKey(n, type: KeyPairType.rsa);
  // }

  /// Verifies the token's signature using RSA-PSS with SHA-256.
  // Future<bool> _verifySignature(
  //   SimplePublicKey publicKey,
  //   List<int> data,
  //   List<int> signature,
  // ) async {
  //   final algorithm = RsaPss(Sha256());
  //   return algorithm.verify(
  //     data,
  //     signature: Signature(signature, publicKey: publicKey),
  //   );
  // }

  /// Validates standard JWT claims.
  ///
  /// Checks:
  /// - Expiration (exp)
  /// - Issuer (iss)
  /// - Audience (aud)
  ///
  /// Throws [TokenValidationException] if any claim is invalid.
  void _validateClaims(Map<String, dynamic> claims) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final exp = claims['exp'];
    if (exp == null || exp is! int || exp < now) {
      throw TokenValidationException('Token expired');
    }

    if (claims['iss'] != issuer) {
      throw TokenValidationException('Issuer mismatch');
    }

    final aud = claims['aud'];
    print('Token aud: $aud');
    print('Expected clientId: $clientId');
    if (aud is String && aud != clientId && aud != 'api://default') {
      throw TokenValidationException('Audience mismatch');
    } else if (aud is List &&
        !(aud.contains(clientId) || aud.contains('api://default'))) {
      throw TokenValidationException('Audience mismatch');
    }
    // if (aud is String && aud != clientId) {
    //   throw TokenValidationException('Audience mismatch');
    // } else if (aud is List && !aud.contains(clientId)) {
    //   throw TokenValidationException('Audience mismatch');
    // }
  }

  String _jwkToPem(Map<String, dynamic> jwk) {
    final modulusBytes = base64Url.decode(base64Url.normalize(jwk['n']));
    final exponentBytes = base64Url.decode(base64Url.normalize(jwk['e']));

    final modulus = _decodeBigInt(modulusBytes);
    final exponent = _decodeBigInt(exponentBytes);

    final publicKeySeq = ASN1Sequence()
      ..add(ASN1Integer(modulus))
      ..add(ASN1Integer(exponent));

    final base64PublicKey = base64.encode(publicKeySeq.encodedBytes);

    final chunks = RegExp(
      r'.{1,64}',
    ).allMatches(base64PublicKey).map((m) => m.group(0)).join('\n');

    return '-----BEGIN RSA PUBLIC KEY-----\n$chunks\n-----END RSA PUBLIC KEY-----';
  }

  BigInt _decodeBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }
}
