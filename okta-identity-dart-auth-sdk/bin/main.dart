import 'package:okta_identity_dart_auth_sdk/src/base/aortem_okta_issue_okta_base_sdk_setup.dart';
import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_auth_login.dart';
import 'package:okta_identity_dart_auth_sdk/src/auth/aortem_okta_issue_okta_social_login.dart';

void main() async {
  // Initialize Okta configuration
  final config = AortemOktaConfig(
    oktaDomain: 'https://your-okta-domain.okta.com',
    clientId: 'your-client-id',
    redirectUri: 'https://yourapp.com/callback',
  );

  // Create base SDK instance
  final baseSDK = AortemOktaBaseSDK(config: config);

  try {
    // Example 1: Username/Password Authentication
    final authLogin = AortemOktaAuthLoginConsumer(baseSDK);
    final tokenResponse = await authLogin.signIn((payload) {
      payload['username'] = 'user@example.com';
      payload['password'] = 'user-password';
    });
    print('Access Token: ${tokenResponse.accessToken}');
    print('ID Token: ${tokenResponse.idToken}');
    print('Refresh Token: ${tokenResponse.refreshToken}');

    // Example 2: Social Login
    final socialLogin = AortemOktaSocialLoginConsumer(
      oktaDomain: config.oktaDomain,
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
