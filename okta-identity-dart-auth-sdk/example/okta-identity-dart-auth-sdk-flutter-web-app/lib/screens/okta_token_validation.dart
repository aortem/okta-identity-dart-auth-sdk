import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
// adjust the import as needed

class TokenValidationScreen extends StatefulWidget {
  const TokenValidationScreen({super.key});

  @override
  State<TokenValidationScreen> createState() => _TokenValidationScreenState();
}

class _TokenValidationScreenState extends State<TokenValidationScreen> {
  final TextEditingController _tokenController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  final validator = OktaTokenValidator(
    oktaDomain: 'dev-07140130.okta.com',
    clientId: '0oaplfz1eaN0o0DLU5d7',
  );

  Future<void> _validate() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final claims = await validator.validateToken(_tokenController.text);
      setState(() {
        _result = '✅ Valid Token\n\nClaims:\n${claims.toString()}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Token validation failed:\n$e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token Validator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Enter JWT Token',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _validate,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Validate Token'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
