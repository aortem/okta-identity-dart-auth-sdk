/// Exception thrown when Okta API requests fail.
class OktaApiException implements Exception {
  /// The HTTP status code from the failed request
  final int statusCode;

  /// The error message from the response
  final String message;

  /// Creates an [OktaApiException] with the given [statusCode] and [message]
  OktaApiException(this.statusCode, this.message);

  @override
  String toString() => 'OktaApiException ($statusCode): $message';
}
