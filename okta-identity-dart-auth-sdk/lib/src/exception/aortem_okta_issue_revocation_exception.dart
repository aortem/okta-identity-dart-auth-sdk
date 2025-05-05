
/// Exception thrown when the Okta API returns an error during token revocation.
///
/// This exception wraps error responses from Okta's token revocation endpoint.
class OktaRevocationException implements Exception {
  /// The error message from the API response
  final String message;
  
  /// Creates an [OktaRevocationException] with the given [message]
  OktaRevocationException(this.message);

  @override
  String toString() => 'OktaRevocationException: $message';
}