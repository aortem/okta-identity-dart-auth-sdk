import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class AppleSignInViewModel {
  final okta-identityAuth auth;

  AppleSignInViewModel({required this.auth});

  Future<UserCredential> signInWithApple(String idToken,
      {String? nonce}) async {
    if (idToken.isEmpty) {
      throw okta-identityAuthException(
        code: 'invalid-id-token',
        message: 'Apple ID Token must not be empty',
      );
    }

    return await auth.signInWithApple(idToken, nonce: nonce);
  }
}
