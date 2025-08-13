import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
import 'dart:html' as html;

class OktaIdentityLogoutScreen extends StatefulWidget {
  const OktaIdentityLogoutScreen({super.key});

  @override
  State<OktaIdentityLogoutScreen> createState() =>
      _OktaIdentityLogoutScreenState();
}

class _OktaIdentityLogoutScreenState extends State<OktaIdentityLogoutScreen> {
  String _message = "Click the button below to logout.";
  bool _isLoading = false;

  Future<void> _performLogout() async {
    setState(() {
      _isLoading = true;
      _message = "Processing logout...";
    });

    final logoutConsumer = OktaIdentityOidcLogoutConsumer(
      oktaIdentityDomain:
          'https://dev-07140130.okta.com', // Replace with your domain
      clientId: '0oaplfz1eaN0o0DLU5d7', // Replace with your Client ID
      postLogoutRedirectUri: 'http://localhost:8080',
    );

    try {
      final logoutUrl = await logoutConsumer.logout(
        modify: (params) async {
          // You can optionally add the ID token hint if stored
          params['id_token_hint'] = 'your_id_token_here'; // optional
        },
      );
      setState(() {
        _message = "Redirecting to logout...";
      });

      html.window.location.href = logoutUrl.toString();
    } catch (e) {
      setState(() {
        _message = "❌ Logout failed: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OktaIdentity OIDC Logout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_message, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _performLogout,
                      child: const Text("Logout from OktaIdentity"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
