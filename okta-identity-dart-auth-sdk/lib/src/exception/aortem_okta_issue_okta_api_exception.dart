/// Exception thrown when OktaIdentity API requests fail.
class OktaIdentityApiException implements Exception {
  /// The HTTP status code from the failed request
  final int statusCode;

  /// The error message from the response
  final String message;

  /// Creates an [OktaIdentityApiException] with the given [statusCode] and [message]
  OktaIdentityApiException(this.statusCode, this.message);

  @override
  String toString() => 'OktaIdentityApiException ($statusCode): $message';
}
