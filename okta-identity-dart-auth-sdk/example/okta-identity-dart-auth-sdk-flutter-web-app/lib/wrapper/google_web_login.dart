@JS()
library google_auth_web;

import 'dart:async';
import 'package:js/js.dart';

@JS('google.accounts.id.initialize')
external void initialize(InitOptions options);

@JS('google.accounts.id.prompt')
external void prompt();

@JS()
@anonymous
class InitOptions {
  external String get client_id;
  external Function get callback;

  external factory InitOptions({String client_id, Function callback});
}

Future<String> fetchGoogleToken() async {
  final completer = Completer<String>();

  initialize(
    InitOptions(
      client_id:
          '727324779430-rljtatkjhd10o0avi9pfu7ple0d86h8o.apps.googleusercontent.com', // replace this
      callback: allowInterop((response) {
        final dynamic credential = response['credential']; // safe cast
        if (credential != null) {
          completer.complete(credential as String);
        } else {
          completer.completeError("Google Web token retrieval failed");
        }
      }),
    ),
  );

  prompt(); // triggers Google popup

  return completer.future;
}
