import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaIdentitySocialLoginService {
  final OktaIdentitySocialLoginConsumer _consumer;

  OktaIdentitySocialLoginService({
    required String oktaIdentityDomain,
    required String clientId,
    required String redirectUri,
  }) : _consumer = OktaIdentitySocialLoginConsumer(
         oktaIdentityDomain: oktaIdentityDomain,
         clientId: clientId,
         redirectUri: redirectUri,
       );

  Future<Map<String, dynamic>> socialSignIn(
    Future<void> Function(Map<String, dynamic>) modifyPayload,
  ) {
    return _consumer.signIn(modifyPayload);
  }
}
