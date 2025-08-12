/// Exception thrown when the OktaIdentity API returns an error during token revocation.
///
/// This exception wraps error responses from OktaIdentity's token revocation endpoint.
class OktaIdentityRevocationException implements Exception {
  /// The error message from the API response
  final String message;

  /// Creates an [OktaIdentityRevocationException] with the given [message]
  OktaIdentityRevocationException(this.message);

  @override
  String toString() => 'OktaIdentityRevocationException: $message';
}
