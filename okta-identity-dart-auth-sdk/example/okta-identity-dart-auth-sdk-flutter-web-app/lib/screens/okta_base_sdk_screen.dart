import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaBaseSDKScreen extends StatefulWidget {
  const OktaBaseSDKScreen({super.key});

  @override
  State<OktaBaseSDKScreen> createState() => _OktaBaseSDKScreenState();
}

class _OktaBaseSDKScreenState extends State<OktaBaseSDKScreen> {
  late OktaBaseSDK _sdk;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  void _initializeSdk() {
    try {
      final config = OktaConfig(
        oktaDomain: 'https://dev-07140130.okta.com',
        clientId: '0oaplfz1eaN0o0DLU5d7',
        redirectUri: 'http://localhost:8080/callback',
        clientSecret: 'yourClientSecret',
      );

      _sdk = OktaBaseSDK(config: config);

      setState(() {
        _status = 'SDK initialized successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error initializing SDK: $e';
      });
    }
  }

  @override
  void dispose() {
    _sdk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Base SDK')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (_status.contains('success')) ...[
              Text('Okta Domain: ${_sdk.config.oktaDomain}'),
              Text('Client ID: ${_sdk.config.clientId}'),
              Text('Redirect URI: ${_sdk.config.redirectUri}'),
            ],
          ],
        ),
      ),
    );
  }
}
