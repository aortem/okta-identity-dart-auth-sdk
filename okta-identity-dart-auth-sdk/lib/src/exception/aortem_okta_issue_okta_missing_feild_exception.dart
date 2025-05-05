
/// Exception thrown when required fields are missing in user operations.
class MissingRequiredFieldException implements Exception {
  /// A message describing the missing field(s)
  final String message;

  /// Creates a [MissingRequiredFieldException] with the given [message]
  MissingRequiredFieldException(this.message);

  @override
  String toString() => 'MissingRequiredFieldException: $message';
}