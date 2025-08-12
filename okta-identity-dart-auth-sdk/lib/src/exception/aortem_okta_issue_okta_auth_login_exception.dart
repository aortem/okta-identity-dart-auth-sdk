/// Exception thrown when the authentication payload is missing required fields.
///
/// This exception is thrown when the payload provided to [OktaAuthLoginConsumer.signIn]
/// doesn't include the required 'username' and 'password' fields.
class OktaAuthPayloadException implements Exception {
  /// A message describing the payload error.
  final String message;

  /// Creates an instance of [OktaAuthPayloadException] with the given [message].
  OktaAuthPayloadException(this.message);

  @override
  String toString() => 'OktaAuthPayloadException: $message';
}
