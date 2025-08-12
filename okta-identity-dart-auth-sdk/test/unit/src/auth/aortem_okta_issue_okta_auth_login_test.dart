import 'package:ds_tools_testing/ds_tools_testing.dart';

import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_auth_login.dart';

import 'package:okta_identity_dart_auth_sdk/src/base/aortem_okta_issue_okta_base_sdk_setup.dart';
import 'package:okta_identity_dart_auth_sdk/src/exception/aortem_okta_issue_okta_auth_login_exception.dart';

class FakeSDK extends OktaIdentityBaseSDK {
  FakeSDK()
    : super(
        config: OktaIdentityConfig(
          oktaIdentityDomain: 'https://fake.okta.com',
          clientId: 'fake-client-id',
          redirectUri: 'fake:/callback',
        ),
      );

  Future<Map<String, dynamic>> sendTokenRequest(
    Map<String, dynamic> payload,
  ) async {
    if (payload['username'] == 'user@example.com' &&
        payload['password'] == 'password123') {
      return {
        'access_token': 'abc123',
        'id_token': 'idToken',
        'refresh_token': 'refreshToken',
        'expires_in': 3600,
        'token_type': 'Bearer',
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }
}

void main() {
  late OktaIdentityAuthLoginConsumer consumer;

  setUp(() {
    consumer = OktaIdentityAuthLoginConsumer(FakeSDK());
  });

  test('throws payload exception for missing password', () async {
    expect(
      () => consumer.signIn((payload) {
        payload['username'] = 'user@example.com';
        // password is missing
      }),
      throwsA(isA<OktaIdentityAuthPayloadException>()),
    );
  });
}
