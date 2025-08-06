import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OktaLoginPage extends StatefulWidget {
  const OktaLoginPage({super.key});

  @override
  State<OktaLoginPage> createState() => _OktaLoginPageState();
}

class _OktaLoginPageState extends State<OktaLoginPage> {
  final String oktaDomain = 'dev-07140130.okta.com';
  final String clientId = '0oaplfz1eaN0o0DLU5d7';
  final String redirectUri = 'http://localhost:8080/callback';

  late String _codeVerifier;
  String? _accessToken;
  String? _idToken;
  String? _error;

  /// Generate a random PKCE code verifier
  String _generateCodeVerifier() {
    final rand = Random.secure();
    final values = List<int>.generate(64, (_) => rand.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Create a SHA256 code challenge from the verifier
  String _generateCodeChallenge(String verifier) {
    final challengeBytes = sha256.convert(utf8.encode(verifier)).bytes;
    return base64UrlEncode(challengeBytes).replaceAll('=', '');
  }

  void _loginWithOkta() {
    _codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(_codeVerifier);

    final uri = Uri.https(oktaDomain, '/oauth2/default/v1/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'scope': 'openid profile email',
      'redirect_uri': redirectUri,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'state': 'customState123',
    });

    // Redirect to Okta login page
    html.window.location.href = uri.toString();
  }

  /// Call this on the callback page
  Future<void> _handleCallback() async {
    final uri = Uri.parse(html.window.location.href);
    final code = uri.queryParameters['code'];
    // final state = uri.queryParameters['state'];

    if (code == null) {
      setState(() => _error = 'Authorization code not found.');
      return;
    }

    final tokenUri = Uri.https(oktaDomain, '/oauth2/default/v1/token');
    final response = await http.post(
      tokenUri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'code_verifier': _codeVerifier,
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _accessToken = data['access_token'];
        _idToken = data['id_token'];
        _error = null;
      });
    } else {
      setState(() {
        _error = data['error_description'] ?? 'Unknown error';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(html.window.location.href);
    if (uri.queryParameters.containsKey('code')) {
      _handleCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Okta Web Auth')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loginWithOkta,
              child: const Text('🔐 Sign in with Okta'),
            ),
            const SizedBox(height: 20),
            if (_accessToken != null) Text('✅ Access Token: $_accessToken'),
            if (_idToken != null) Text('🆔 ID Token: $_idToken'),
            if (_error != null) Text('❌ Error: $_error'),
          ],
        ),
      ),
    );
  }
}
