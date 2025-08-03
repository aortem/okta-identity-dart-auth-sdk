/// Exception thrown when the authentication payload is missing required fields.
///
/// This exception is thrown when the payload provided to [AortemOktaAuthLoginConsumer.signIn]
/// doesn't include the required 'username' and 'password' fields.
class AortemOktaAuthPayloadException implements Exception {
  /// A message describing the payload error.
  final String message;

  /// Creates an instance of [AortemOktaAuthPayloadException] with the given [message].
  AortemOktaAuthPayloadException(this.message);

  @override
  String toString() => 'AortemOktaAuthPayloadException: $message';
}
