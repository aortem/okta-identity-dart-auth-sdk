import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaUtilityScreen extends StatefulWidget {
  const OktaUtilityScreen({super.key});

  @override
  State<OktaUtilityScreen> createState() => _OktaUtilityScreenState();
}

class _OktaUtilityScreenState extends State<OktaUtilityScreen> {
  final okta = OktaUtilityMethods(
    oktaDomain: 'https://dev-123456.okta.com', // Replace with your Okta domain
    apiToken: 'yourApiToken', // Replace with your API token
  );

  String signInUrl = '';
  String delegatedResponse = '';
  final _clientIdController = TextEditingController();
  final _redirectUriController = TextEditingController();
  final _delegatedRequestIdController = TextEditingController();

  Future<void> _generateSignInLink() async {
    try {
      final url = await okta.getSignInLink(
        redirectUri: _redirectUriController.text,
        clientId: _clientIdController.text,
      );
      setState(() {
        signInUrl = url;
      });
    } catch (e) {
      setState(() {
        signInUrl = 'Error: $e';
      });
    }
  }

  Future<void> _acceptDelegatedAccess() async {
    try {
      final response = await okta.acceptDelegatedRequest(
        requestId: _delegatedRequestIdController.text,
      );
      setState(() {
        delegatedResponse = response.toString();
      });
    } catch (e) {
      setState(() {
        delegatedResponse = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _redirectUriController.dispose();
    _delegatedRequestIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Utility Methods UI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Sign-In Link',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _clientIdController,
                decoration: const InputDecoration(labelText: 'Client ID'),
              ),
              TextField(
                controller: _redirectUriController,
                decoration: const InputDecoration(labelText: 'Redirect URI'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _generateSignInLink,
                child: const Text('Generate Link'),
              ),
              SelectableText('Sign-In URL: $signInUrl'),

              const Divider(height: 40),

              const Text(
                'Accept Delegated Request',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _delegatedRequestIdController,
                decoration: const InputDecoration(
                  labelText: 'Delegated Request ID',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _acceptDelegatedAccess,
                child: const Text('Accept Request'),
              ),
              SelectableText('Response: $delegatedResponse'),
            ],
          ),
        ),
      ),
    );
  }
}
