import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaSocialLoginService {
  final OktaSocialLoginConsumer _consumer;

  OktaSocialLoginService({
    required String oktaDomain,
    required String clientId,
    required String redirectUri,
  }) : _consumer = OktaSocialLoginConsumer(
         oktaDomain: oktaDomain,
         clientId: clientId,
         redirectUri: redirectUri,
       );

  Future<Map<String, dynamic>> socialSignIn(
    Future<void> Function(Map<String, dynamic>) modifyPayload,
  ) {
    return _consumer.signIn(modifyPayload);
  }
}
