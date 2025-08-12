import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
// import '../services/authenticator_management.dart';

class AuthenticatorTestScreen extends StatefulWidget {
  const AuthenticatorTestScreen({super.key});

  @override
  State<AuthenticatorTestScreen> createState() =>
      _AuthenticatorTestScreenState();
}

class _AuthenticatorTestScreenState extends State<AuthenticatorTestScreen> {
  final _manager = OktaAuthenticatorManagement(
    oktaDomain: 'dev-07140130.okta.com', // <-- replace with your Okta domain
    apiToken:
        'your_api_token_here', // <-- securely store this, avoid hardcoding
  );

  final String userId = 'your_user_id_here'; // <-- replace with actual user ID

  List<Map<String, dynamic>> authenticators = [];

  Future<void> _addAuthenticator() async {
    try {
      final response = await _manager.addAuthenticator(
        userId: userId,
        payloadBuilder: () => {
          'authenticatorType': 'sms',
          'provider': 'OKTA',
          'profile': {'phoneNumber': '+15551234567'},
        },
      );
      debugPrint('Added: $response');
    } catch (e) {
      debugPrint('Add Error: $e');
    }
  }

  Future<void> _listAuthenticators() async {
    try {
      final list = await _manager.listAuthenticators(userId: userId);
      setState(() => authenticators = list);
    } catch (e) {
      debugPrint('List Error: $e');
    }
  }

  Future<void> _deleteAuthenticator(String factorId) async {
    try {
      await _manager.deleteAuthenticator(userId: userId, factorId: factorId);
      debugPrint('Deleted $factorId');
      _listAuthenticators();
    } catch (e) {
      debugPrint('Delete Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticator Management')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addAuthenticator,
            child: const Text('Add Authenticator'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _listAuthenticators,
            child: const Text('List Authenticators'),
          ),
          const Divider(),
          ...authenticators.map(
            (auth) => ListTile(
              title: Text(auth['factorType'] ?? 'Unknown Factor'),
              subtitle: Text(auth['id']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteAuthenticator(auth['id']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
