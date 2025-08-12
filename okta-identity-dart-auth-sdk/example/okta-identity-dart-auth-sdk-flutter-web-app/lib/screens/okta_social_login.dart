import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaSocialLoginScreen extends StatefulWidget {
  const OktaSocialLoginScreen({super.key});

  @override
  State<OktaSocialLoginScreen> createState() => _OktaSocialLoginScreenState();
}

class _OktaSocialLoginScreenState extends State<OktaSocialLoginScreen> {
  String result = '';
  bool isLoading = false;

  void _simulateGoogleLogin() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    final socialLoginConsumer = OktaSocialLoginConsumer(
      oktaDomain: 'https://dev-07140130.okta.com',
      clientId: '0oaplfz1eaN0o0DLU5d7',
      redirectUri: 'http://localhost:8080/callback',
    );

    try {
      final response = await socialLoginConsumer.signIn((payload) {
        payload['provider'] = 'google';
        payload['social_token'] = 'mock_google_token'; // 🔸 No real login
        payload['scope'] = 'openid profile email';
      });

      setState(() {
        result = '✅ Social login mock successful:\n${response.toString()}';
      });
    } catch (e) {
      setState(() {
        result = '❌ Social login failed: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Social Login Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Click below to simulate Google Sign-In with Okta SDK',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _simulateGoogleLogin,
              icon: const Icon(Icons.login),
              label: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign in with Google'),
            ),
            const SizedBox(height: 24),
            Text(result),
          ],
        ),
      ),
    );
  }
}
