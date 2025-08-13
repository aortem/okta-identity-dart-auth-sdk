/// Exception thrown when token validation fails.
///
/// This exception indicates various validation failures including:
/// - Invalid token format
/// - Signature verification failure
/// - Expired tokens
/// - Issuer/audience mismatches
class TokenValidationException implements Exception {
  /// A message describing the validation failure
  final String message;

  /// Creates a [TokenValidationException] with the given [message]
  TokenValidationException(this.message);

  @override
  String toString() => 'TokenValidationException: $message';
}
