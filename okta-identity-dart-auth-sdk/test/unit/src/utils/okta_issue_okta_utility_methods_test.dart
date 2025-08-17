import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() {
  group('OktaIdentityUtilityMethods', () {
    late OktaIdentityUtilityMethods oktaUtility;

    group('getSignInLink', () {
      test('should throw exception on failure', () async {
        oktaUtility = OktaIdentityUtilityMethods(
          oktaIdentityDomain: 'https://your-org.okta.com',
          apiToken: 'mock-api-token',
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
        oktaUtility = OktaIdentityUtilityMethods(
          oktaIdentityDomain: 'https://your-org.okta.com',
          apiToken: 'mock-api-token',
        );

        expect(
          () async =>
              await oktaUtility.acceptDelegatedRequest(requestId: '12345'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
