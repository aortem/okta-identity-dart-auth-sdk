import 'package:ds_standard_features/ds_standard_features.dart' as http;
import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:okta_identity_dart_auth_sdk/src/utils/aortem_okta_issue_okta_utility_methods.dart';

void main() {
  group('AortemOktaUtilityMethods', () {
    late AortemOktaUtilityMethods oktaUtility;
    late MockClient mockClient;

    group('getSignInLink', () {
      test('should throw exception on failure', () async {
        mockClient = MockClient((request) async {
          return http.Response('Error', 500);
        });

        oktaUtility = AortemOktaUtilityMethods(
          oktaDomain: 'https://your-org.okta.com',
          apiToken: 'mock-api-token',
          client: mockClient,
        );

        expect(
          () async => await oktaUtility.getSignInLink(
            redirectUri: 'com.example:/callback',
            clientId: 'mock-client-id',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('acceptDelegatedRequest', () {
      test('should throw exception on failure', () async {
        mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, '/api/v1/delegatedRequests/12345/accept');
          return http.Response('Error', 500);
        });

        oktaUtility = AortemOktaUtilityMethods(
          oktaDomain: 'https://your-org.okta.com',
          apiToken: 'mock-api-token',
          client: mockClient,
        );

        expect(
          () async => await oktaUtility.acceptDelegatedRequest(
            requestId: '12345',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
