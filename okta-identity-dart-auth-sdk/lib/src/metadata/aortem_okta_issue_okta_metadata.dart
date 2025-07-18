import 'dart:convert';
import 'package:ds_standard_features/ds_standard_features.dart' as http;

/// A class for retrieving and caching Okta OpenID Connect metadata.
///
/// This class handles fetching and caching the OpenID Connect configuration
/// metadata from Okta's well-known endpoint. The metadata includes important
/// OAuth 2.0 and OpenID Connect endpoints like:
/// - Authorization endpoint
/// - Token endpoint
/// - JWKS URI
/// - Issuer information
///
/// The metadata is automatically cached for 10 minutes to reduce network calls.
class AortemOktaMetadata {
  /// The base domain of the Okta organization (e.g., 'your-org.okta.com')
  final String oktaDomain;

  /// The HTTP client used for making requests
  final http.Client httpClient;

  /// Cache for storing the metadata
  Map<String, dynamic>? _cachedMetadata;

  /// Expiration time for the cached metadata
  DateTime? _cacheExpiry;

  /// Creates an instance of [AortemOktaMetadata].
  ///
  /// Required parameters:
  /// - [oktaDomain]: The base domain of your Okta organization
  ///
  /// Optional parameters:
  /// - [httpClient]: Custom HTTP client instance (defaults to [http.Client])
  AortemOktaMetadata({required this.oktaDomain, http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  /// Fetches the OpenID Connect metadata from Okta's well-known endpoint.
  ///
  /// The metadata is cached for 10 minutes to avoid unnecessary network calls.
  /// Subsequent calls within the cache period will return the cached version.
  ///
  /// The metadata includes:
  /// - issuer
  /// - authorization_endpoint
  /// - token_endpoint
  /// - jwks_uri
  /// - And other OpenID Connect configuration values
  ///
  /// Example:
  /// ```dart
  /// final metadata = AortemOktaMetadata(oktaDomain: 'your-org.okta.com');
  /// final config = await metadata.getMetadata();
  /// print('Token endpoint: ${config['token_endpoint']}');
  /// ```
  ///
  /// @return [Future<Map<String, dynamic>>] A map containing the OpenID Connect metadata
  /// @throws Exception If the request fails or the metadata is invalid
  Future<Map<String, dynamic>> getMetadata() async {
    // Return cached metadata if available and not expired
    if (_cachedMetadata != null &&
        _cacheExpiry != null &&
        DateTime.now().isBefore(_cacheExpiry!)) {
      return _cachedMetadata!;
    }

    // Construct the well-known OpenID configuration URL
    final String metadataUrl =
        'https://$oktaDomain/.well-known/openid-configuration';

    try {
      final response = await httpClient.get(Uri.parse(metadataUrl));

      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> metadata = jsonDecode(response.body);

        // Validate required OpenID Connect metadata fields
        if (!metadata.containsKey('issuer') ||
            !metadata.containsKey('authorization_endpoint') ||
            !metadata.containsKey('token_endpoint') ||
            !metadata.containsKey('jwks_uri')) {
          throw Exception('Missing required fields in Okta metadata');
        }

        // Cache the metadata with a 10 minute expiration
        _cachedMetadata = metadata;
        _cacheExpiry = DateTime.now().add(const Duration(minutes: 10));

        return metadata;
      } else {
        throw Exception(
          'Failed to fetch metadata from Okta. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error retrieving Okta metadata: $e');
    }
  }

  /// Manually invalidates the cached metadata.
  ///
  /// Forces the next call to [getMetadata] to fetch fresh data from Okta.
  void invalidateCache() {
    _cachedMetadata = null;
    _cacheExpiry = null;
  }
}
