import 'package:bot_toast/bot_toast.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
import 'package:flutter/material.dart';

class SignInWithEmailAndPasswordViewModel extends ChangeNotifier {
  bool loading = false;
  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  Future<void> signIn(
      String email, String password, VoidCallback onSuccess) async {
    try {
      setLoading(true);

      await okta -
          identityApp.okta -
          identityAuth?.signInWithEmailAndPassword(email, password);

      onSuccess();
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
    setLoading(false);
  }
}
