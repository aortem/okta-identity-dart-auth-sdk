import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class IdpSsoTestScreen extends StatefulWidget {
  const IdpSsoTestScreen({super.key});

  @override
  State<IdpSsoTestScreen> createState() => _IdpSsoTestScreenState();
}

class _IdpSsoTestScreenState extends State<IdpSsoTestScreen> {
  final _oktaDomain = 'dev-123456.okta.com'; // Replace with your domain
  final _clientId = '0oaplfz1eaN0o0DLU5d7'; // Replace with your clientId
  final _relayState =
      'https://localhost:8080/callback'; // Can be app link or URL

  String? _ssoUrl;
  String? _error;

  void _buildSsoUrl() {
    try {
      final sso = AortemOktaIdpInitiatedSSO(
        oktaDomain: _oktaDomain,
        clientId: _clientId,
        defaultRelayState: _relayState,
      );

      final url = sso.initiateIdpSso((params) {
        params['login_hint'] = 'user@example.com'; // Optional custom param
        params['customParam'] = 'flutterWeb';
      });

      setState(() {
        _ssoUrl = url;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _ssoUrl = null;
      });
    }
  }

  void _redirectToSso() {
    if (_ssoUrl != null) {
      html.window.location.href = _ssoUrl!;
    }
  }

  @override
  void initState() {
    super.initState();
    _buildSsoUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧪 IdP-Initiated SSO Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Build SSO URL'),
              onPressed: _buildSsoUrl,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                '❌ Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
            else if (_ssoUrl != null) ...[
              const Text(
                '✅ Generated SSO URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(_ssoUrl!, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _redirectToSso,
                icon: const Icon(Icons.login),
                label: const Text('Redirect to SSO'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
