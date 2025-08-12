import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
import 'dart:html' as html;

class OktaAuthScreen extends StatefulWidget {
  const OktaAuthScreen({super.key});

  @override
  State<OktaAuthScreen> createState() => _OktaAuthScreenState();
}

class _OktaAuthScreenState extends State<OktaAuthScreen> {
  late AortemOktaAuthorization _auth;
  String? _authUrl;
  String? _tokenResult;
  final String clientId = 'your-client-id';
  final String oktaDomain = 'dev-123456.okta.com';
  final String redirectUri =
      'http://localhost:1234/callback'; // Update for web origin

  @override
  void initState() {
    super.initState();
    _auth = AortemOktaAuthorization(
      clientId: clientId,
      redirectUri: redirectUri,
      oktaDomain: oktaDomain,
    );
  }

  void _launchAuthorizationFlow() {
    final uri = _auth.authorizeApplication((params) {
      params['scope'] = 'openid profile email';
      params['state'] = 'abc123';
      params['code_challenge'] = 'dummy_challenge';
      params['code_challenge_method'] = 'plain';
    });

    setState(() {
      _authUrl = uri.toString();
    });

    html.window.location.href = uri.toString();
  }

  Future<void> _handleRedirectAndExchangeCode() async {
    final uri = Uri.parse(html.window.location.href);
    final code = uri.queryParameters['code'];
    if (code != null) {
      try {
        final tokens = await _auth.authorizeEndpoint((params) {
          params['code'] = code;
          params['code_verifier'] = 'dummy_challenge';
        });
        setState(() {
          _tokenResult = tokens.toString();
        });
      } catch (e) {
        setState(() {
          _tokenResult = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Auth Sample')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _launchAuthorizationFlow,
              child: const Text('Start Authorization'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _handleRedirectAndExchangeCode,
              child: const Text('Handle Callback & Exchange Code'),
            ),
            const SizedBox(height: 24),
            if (_authUrl != null) Text('Redirecting to: $_authUrl'),
            const SizedBox(height: 12),
            if (_tokenResult != null) Text('Token Response:$_tokenResult'),
          ],
        ),
      ),
    );
  }
}
