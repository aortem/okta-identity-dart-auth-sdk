import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class TokenExchangeScreen extends StatefulWidget {
  const TokenExchangeScreen({super.key});

  @override
  State<TokenExchangeScreen> createState() => _TokenExchangeScreenState();
}

class _TokenExchangeScreenState extends State<TokenExchangeScreen> {
  final _authCodeController = TextEditingController();
  final _refreshTokenController = TextEditingController();
  String _result = '';
  bool _loading = false;

  final _tokenExchange = OktaIdentityTokenExchangeConsumer(
    oktaIdentityDomain: 'https://dev-123456.okta.com',
    clientId: 'yourClientId',
    redirectUri: 'com.example.app:/callback',
    clientSecret: 'yourClientSecretIfNeeded',
  );

  Future<void> _exchangeAuthCode() async {
    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final tokens = await _tokenExchange.exchangeToken(
        modifyPayload: (payload) async {
          payload['grant_type'] = 'authorization_code';
          payload['code'] = _authCodeController.text;
          payload['code_verifier'] =
              'dummy_code_verifier'; // replace with actual
        },
      );
      setState(() {
        _result = const JsonEncoder.withIndent('  ').convert(tokens);
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final tokens = await _tokenExchange.exchangeToken(
        modifyPayload: (payload) async {
          payload['grant_type'] = 'refresh_token';
          payload['refresh_token'] = _refreshTokenController.text;
          payload['scope'] = 'openid profile email';
        },
      );
      setState(() {
        _result = const JsonEncoder.withIndent('  ').convert(tokens);
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OktaIdentity Token Exchange')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Authorization Code Flow'),
            TextField(
              controller: _authCodeController,
              decoration: const InputDecoration(
                labelText: 'Authorization Code',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _exchangeAuthCode,
              child: const Text('Exchange Auth Code'),
            ),
            const SizedBox(height: 24),
            const Text('Refresh Token Flow'),
            TextField(
              controller: _refreshTokenController,
              decoration: const InputDecoration(labelText: 'Refresh Token'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _refreshToken,
              child: const Text('Refresh Access Token'),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_result.isNotEmpty)
              SelectableText(
                _result,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
          ],
        ),
      ),
    );
  }
}
