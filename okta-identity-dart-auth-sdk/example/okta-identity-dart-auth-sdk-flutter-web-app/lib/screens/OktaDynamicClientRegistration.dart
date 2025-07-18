import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

/// Flutter UI to test the SDK feature
class DynamicClientRegistrationScreen extends StatefulWidget {
  const DynamicClientRegistrationScreen({super.key});

  @override
  State<DynamicClientRegistrationScreen> createState() =>
      _DynamicClientRegistrationScreenState();
}

class _DynamicClientRegistrationScreenState
    extends State<DynamicClientRegistrationScreen> {
  String? _result;
  String? _error;
  bool _loading = false;

  Future<void> _registerClient() async {
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    final registrar = AortemOktaDynamicClientRegistration(
      oktaDomain: 'dev-123456.okta.com', // Replace with your Okta domain
    );

    try {
      final response = await registrar.registerClient((payload) {
        payload['redirect_uris'] = [
          'https://flutterweb.okta/callback',
          'com.flutterweb:/callback',
        ];
        payload['client_name'] = 'Flutter Web Test Client';
        payload['grant_types'] = ['authorization_code'];
        payload['response_types'] = ['code'];
        payload['token_endpoint_auth_method'] = 'none';
      });

      setState(() {
        _result = const JsonEncoder.withIndent('  ').convert(response);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛠 Dynamic Client Registration')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _registerClient,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Register Client'),
            ),
            const SizedBox(height: 20),
            if (_result != null) ...[
              const Text(
                '✅ Registration Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(_result!),
            ] else if (_error != null) ...[
              const Text(
                '❌ Error:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SelectableText(_error!),
            ],
          ],
        ),
      ),
    );
  }
}
