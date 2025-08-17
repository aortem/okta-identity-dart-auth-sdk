/// Exception thrown when the authentication payload is missing required fields.
///
/// This exception is thrown when the payload provided to [OktaIdentityAuthLoginConsumer.signIn]
/// doesn't include the required 'username' and 'password' fields.
class OktaIdentityAuthPayloadException implements Exception {
  /// A message describing the payload error.
  final String message;

  /// Creates an instance of [OktaIdentityAuthPayloadException] with the given [message].
  OktaIdentityAuthPayloadException(this.message);

  @override
  String toString() => 'OktaIdentityAuthPayloadException: $message';
}
