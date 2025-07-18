import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaUtilityScreen extends StatefulWidget {
  const OktaUtilityScreen({super.key});

  @override
  State<OktaUtilityScreen> createState() => _OktaUtilityScreenState();
}

class _OktaUtilityScreenState extends State<OktaUtilityScreen> {
  String output = '';

  final String oktaDomain = 'dev-123456.okta.com';
  final String clientId = 'your-client-id';
  final String redirectUri = 'http://localhost:8080/callback';
  final String apiToken = 'your-api-token';
  final String requestId = 'your-request-id';

  Future<void> generateSignInLink() async {
    try {
      final util = AortemOktaUtilityMethods(
        oktaDomain: oktaDomain,
        apiToken: apiToken,
      );
      final url = await util.getSignInLink(
        clientId: clientId,
        redirectUri: redirectUri,
      );
      setState(() => output = 'Sign-in URL:\n$url');
    } catch (e) {
      setState(() => output = 'Error: $e');
    }
  }

  Future<void> acceptDelegation() async {
    try {
      final util = AortemOktaUtilityMethods(
        oktaDomain: oktaDomain,
        apiToken: apiToken,
      );
      final result = await util.acceptDelegatedRequest(requestId: requestId);
      setState(() => output = 'Delegation Response:\n$result');
    } catch (e) {
      setState(() => output = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Utility Methods')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: generateSignInLink,
              child: const Text('Generate Sign-In Link'),
            ),
            ElevatedButton(
              onPressed: acceptDelegation,
              child: const Text('Accept Delegated Request'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(child: SelectableText(output)),
            ),
          ],
        ),
      ),
    );
  }
}
