import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaTokenRevocationScreen extends StatefulWidget {
  const OktaTokenRevocationScreen({super.key});

  @override
  State<OktaTokenRevocationScreen> createState() =>
      _OktaTokenRevocationScreenState();
}

class _OktaTokenRevocationScreenState extends State<OktaTokenRevocationScreen> {
  final String _oktaDomain = 'https://dev-07140130.okta.com';
  final String _clientId = 'your_client_id_here';
  final String _clientSecret = 'your_client_secret_here';

  String? _accessToken;
  String? _idToken;
  String _status = '';

  Future<void> _simulateLogin() async {
    // Simulate login tokens (you should replace with real tokens from login flow)
    setState(() {
      _accessToken = 'your_access_token_here';
      _idToken = 'your_id_token_here';
      _status = '✅ Tokens set (simulated login)';
    });
  }

  Future<void> _revokeToken({
    required String token,
    required String type,
  }) async {
    try {
      final revoker = AortemOktaGlobalTokenRevocationConsumer(
        oktaDomain: _oktaDomain,
        clientId: _clientId,
        clientSecret: _clientSecret,
      );

      await revoker.revokeToken(
        buildPayload: (builder) {
          builder.setToken(token);
          builder.setTokenTypeHint(
            type,
          ); // access_token, refresh_token, or id_token
        },
      );

      setState(() {
        _status = '🗑️ Token of type `$type` successfully revoked!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Revocation failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Token Revocation Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔐 Token Revocation Flow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _simulateLogin,
              child: const Text('🔓 Simulate Login (Set Tokens)'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _accessToken != null
                  ? () =>
                        _revokeToken(token: _accessToken!, type: 'access_token')
                  : null,
              child: const Text('🗑️ Revoke Access Token'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _idToken != null
                  ? () => _revokeToken(token: _idToken!, type: 'id_token')
                  : null,
              child: const Text('🗑️ Revoke ID Token'),
            ),
            const SizedBox(height: 20),

            const Text('📋 Status:'),
            SelectableText(
              _status,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
