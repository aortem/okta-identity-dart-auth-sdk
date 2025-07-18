import 'package:bot_toast/bot_toast.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
import 'package:flutter/material.dart';

class VerifyBeforeEmailUpdateViewModel extends ChangeNotifier {
  final OktaIdentityAuth? _okta-identitySdk = OktaIdentityApp.OktaIdentityAuth;
  bool loading = false;

  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  Future<void> verifyBeforeEmailUpdate(
    String newEmail, {
    ActionCodeSettings? actionCode,
    required VoidCallback onFinished,
  }) async {
    try {
      setLoading(true);
      await _okta-identitySdk?.verifyBeforeEmailUpdate(newEmail, action: actionCode);
      BotToast.showText(text: 'Verification email has been sent to $newEmail');
      onFinished();
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      setLoading(false);
    }
  }
}
