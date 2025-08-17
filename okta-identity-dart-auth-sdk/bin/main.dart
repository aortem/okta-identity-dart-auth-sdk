import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

void main() async {
  // Initialize OktaIdentity configuration
  final config = OktaIdentityConfig(
    oktaIdentityDomain: 'https://dev-07140130.okta.com',
    clientId: '0oaplfz1eaN0o0DLU5d7',
    clientSecret:
        'MZhEzzq5mVHh7eWd-6xVHCmsITbeZc-w-RU8gVfycT-s1cj2V-ZL5hCjiA2lFAYm',
    redirectUri: 'http://localhost:8080/authorization-code/callback',
  );

  // Create base SDK instance
  final baseSDK = OktaIdentityBaseSDK(config: config);

  try {
    // Example 1: Username/Password Authentication
    final authLogin = OktaIdentityAuthLoginConsumer(baseSDK);
    final tokenResponse = await authLogin.signIn((payload) {
      payload['username'] = 'developers@aortem.io';
      payload['password'] = 'Hello@1234';
    });
    print('Access Token: ${tokenResponse.accessToken}');
    print('ID Token: ${tokenResponse.idToken}');
    print('Refresh Token: ${tokenResponse.refreshToken}');

    // Example 2: Social Login
    final socialLogin = OktaIdentitySocialLoginConsumer(
      oktaIdentityDomain: config.oktaIdentityDomain,
      clientId: config.clientId,
      redirectUri: config.redirectUri,
    );
    final socialResponse = await socialLogin.signIn((payload) {
      payload['provider'] = 'google';
      payload['social_token'] = 'google-auth-token';
    });
    print('Social Login Access Token: ${socialResponse['access_token']}');
  } catch (e) {
    print('Authentication failed: $e');
  } finally {
    // Clean up resources
    baseSDK.dispose();
  }
}
