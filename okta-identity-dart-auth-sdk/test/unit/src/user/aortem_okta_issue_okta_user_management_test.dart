import 'package:ds_tools_testing/ds_tools_testing.dart';
import 'package:okta_identity_dart_auth_sdk/src/exception/aortem_okta_issue_okta_missing_feild_exception.dart';
import 'package:okta_identity_dart_auth_sdk/src/user/aortem_okta_issue_okta_user_management.dart';

void main() {
  group('OktaIdentityUserManagementConsumer', () {
    late OktaIdentityUserManagementConsumer consumer;

    setUp(() {
      consumer = OktaIdentityUserManagementConsumer(
        oktaIdentityDomain: 'https://mock.okta.com',
        apiToken: 'dummy-token',
      );
    });

    test(
      'signUp - missing fields throws MissingRequiredFieldException',
      () async {
        expect(
          () => consumer.signUp(
            buildPayload: (builder) {
              builder.setLogin('missing@example.com'); // No password or email
            },
          ),
          throwsA(isA<MissingRequiredFieldException>()),
        );
      },
    );

    test('signUp - bad request throws OktaIdentityApiException', () async {
      final badConsumer = OktaIdentityUserManagementConsumer(
        oktaIdentityDomain: 'https://mock.okta.com',
        apiToken: 'dummy-token',
      );

      expect(
        () => badConsumer.signUp(
          buildPayload: (builder) {
            // Send incomplete payload
            builder.setEmail('bad@example.com');
          },
        ),
        throwsA(isA<MissingRequiredFieldException>()),
      );
    });
  });
}
