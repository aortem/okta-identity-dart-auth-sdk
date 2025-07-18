import 'package:flutter/material.dart';
// import '../services/aortem_okta_token_validator.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class TokenValidation extends StatefulWidget {
  final String token;
  const TokenValidation({required this.token, super.key});

  @override
  State<TokenValidation> createState() => _TokenValidationState();
}

class _TokenValidationState extends State<TokenValidation> {
  String? result;

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  Future<void> _validateToken() async {
    final validator = AortemOktaTokenValidator(
      oktaDomain: 'dev-07140130.okta.com',
      clientId: '0oaplfz1eaN0o0DLU5d7',
    );

    try {
      final claims = await validator.validateToken(widget.token);
      setState(() {
        result = '✅ Valid token\n\nClaims:\n$claims';
      });
    } catch (e) {
      setState(() {
        result = '❌ Token validation failed\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validate Token")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(result ?? "Validating..."),
        ),
      ),
    );
  }
}
