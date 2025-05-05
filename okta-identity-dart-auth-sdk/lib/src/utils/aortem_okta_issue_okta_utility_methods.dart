import 'dart:convert';

import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:http/src/mock_client.dart';

/// Provides utility methods for interacting with Okta APIs
/// Handles common operations like generating sign-in links and managing delegated access
class AortemOktaUtilityMethods {
  /// The base domain of the Okta organization (e.g. 'https://your-org.okta.com')
  final String oktaDomain;

  /// The API token used for authenticating with Okta's APIs
  final String apiToken;

  /// Creates an instance of AortemOktaUtilityMethods
  ///
  /// @param oktaDomain The base URL of your Okta organization
  /// @param apiToken A valid API token with necessary permissions
  AortemOktaUtilityMethods(
      {required this.oktaDomain,
      required this.apiToken,
      required MockClient client});

  /// Generates a sign-in URL for OAuth 2.0 authorization code flow
  ///
  /// @param redirectUri The URI where Okta should redirect after authentication
  /// @param clientId The client ID of your Okta OAuth application
  /// @return Future<String> containing the sign-in URL
  /// @throws Exception if the request fails or response is invalid
  Future<String> getSignInLink(
      {required String redirectUri, required String clientId}) async {
    // Prepare the request body with OAuth2 parameters
    final Map<String, String> requestBody = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'openid profile email', // Default scopes for OpenID Connect
    };

    // Send request to Okta's authorization endpoint
    final response = await _sendRequest(
      'POST',
      Uri.parse('$oktaDomain/oauth2/v1/authorize'),
      body: jsonEncode(requestBody),
    );

    // Extract and return the sign-in URL from the response
    return response['sign_in_url'];
  }

  /// Accepts a delegated access request in Okta
  ///
  /// @param requestId The ID of the delegated access request to accept
  /// @return Future<Map<String, dynamic>> containing the response from Okta
  /// @throws Exception if the request fails or response is invalid
  Future<Map<String, dynamic>> acceptDelegatedRequest(
      {required String requestId}) async {
    // Prepare the request body with acceptance action
    final Map<String, String> requestBody = {
      'request_id': requestId,
      'action': 'accept', // Action to accept the delegated request
    };

    // Send request to Okta's delegated requests endpoint
    final response = await _sendRequest(
      'POST',
      Uri.parse('$oktaDomain/api/v1/delegatedRequests/$requestId/accept'),
      body: jsonEncode(requestBody),
    );

    return response;
  }

  /// Internal helper method to send authenticated HTTP requests to Okta
  ///
  /// @param method The HTTP method ('GET' or 'POST')
  /// @param url The full URL to request
  /// @param body Optional request body for POST requests
  /// @return Future<Map<String, dynamic>> containing the parsed JSON response
  /// @throws Exception if the request fails or returns non-200 status
  Future<Map<String, dynamic>> _sendRequest(String method, Uri url,
      {String? body}) async {
    try {
      // Set up headers with authorization and content type
      final headers = {
        'Authorization': 'Bearer $apiToken', // Bearer token authentication
        'Content-Type': 'application/json', // JSON content type
      };

      // Execute the HTTP request based on method
      final response = await (method == 'POST'
          ? http.post(url, headers: headers, body: body)
          : http.get(url, headers: headers));

      // Check for successful response status
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to perform request. Status Code: ${response.statusCode}');
      }

      // Parse and return the JSON response body
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error performing request: $e');
    }
  }
}
