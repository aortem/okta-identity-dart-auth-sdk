/// Exception thrown when the required token is missing in the revocation request.
///
/// This exception indicates that a token revocation attempt was made without
/// providing the required token parameter.
class MissingTokenFieldException implements Exception {
  /// A message describing the error
  final String message;

  /// Creates a [MissingTokenFieldException] with an optional custom [message]
  MissingTokenFieldException(
      [this.message = 'Token is required for revocation.']);

  @override
  String toString() => 'MissingTokenFieldException: $message';
}
