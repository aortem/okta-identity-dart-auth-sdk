import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaAuthService {
  final AortemOktaBaseSDK baseSDK;

  OktaAuthService({
    required String oktaDomain,
    required String clientId,
    required String redirectUri,
    String? clientSecret,
  }) : baseSDK = AortemOktaBaseSDK(
         config: AortemOktaConfig(
           oktaDomain: oktaDomain,
           clientId: clientId,
           redirectUri: redirectUri,
           clientSecret: clientSecret,
         ),
       );

  Future<void> signInWithUsernamePassword({
    required String username,
    required String password,
  }) async {
    final authLogin = AortemOktaAuthLoginConsumer(baseSDK);
    try {
      final tokenResponse = await authLogin.signIn((payload) {
        payload['username'] = username;
        payload['password'] = password;
        payload['scope'] = 'openid profile email'; // Optional
      });

      print('Access Token: ${tokenResponse.accessToken}');
      print('ID Token: ${tokenResponse.idToken}');
      print('Refresh Token: ${tokenResponse.refreshToken}');
    } catch (e) {
      print('Login failed: $e');
    }
  }
}
