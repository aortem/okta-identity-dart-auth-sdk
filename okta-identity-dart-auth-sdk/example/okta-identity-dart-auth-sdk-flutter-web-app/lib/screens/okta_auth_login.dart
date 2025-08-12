import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class OktaIdentityAuthLoginScreen extends StatefulWidget {
  const OktaIdentityAuthLoginScreen({super.key});

  @override
  State<OktaIdentityAuthLoginScreen> createState() =>
      _OktaIdentityAuthLoginScreenState();
}

class _OktaIdentityAuthLoginScreenState
    extends State<OktaIdentityAuthLoginScreen> {
  // final TextEditingController _usernameController = TextEditingController(
  //   text: 'developers@aortem.io',
  // );
  // final TextEditingController _passwordController = TextEditingController(
  //   text: 'Hello@1234',
  // );
  // final _oktaIdentityDomain = 'https://dev-07140130.okta.com';
  final _oktaIdentityDomain = 'dev-07140130.okta.com';
  final _clientId = '0oaplfz1eaN0o0DLU5d7';
  final _redirectUri = 'http://localhost:8080/callback'; // match your okta app

  String? _result;
  String? _idToken;

  @override
  void initState() {
    super.initState();
    _checkForCallback();
  }

  void _generateAndStorePkcePair() {
    final verifier = _generateRandomString(64);
    final challenge = _base64UrlEncodeNoPadding(
      sha256.convert(utf8.encode(verifier)).bytes,
    );

    html.window.localStorage['pkce_code_verifier'] = verifier;
    html.window.localStorage['pkce_code_challenge'] = challenge;
  }

  String _generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  String _base64UrlEncodeNoPadding(List<int> input) {
    return base64Url.encode(input).replaceAll('=', '');
  }

  void _checkForCallback() async {
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('code')) {
      setState(() => _result = "🔁 Handling callback...");

      final tokenHandler = OktaIdentityTokenExchangeConsumer(
        oktaIdentityDomain: _oktaIdentityDomain,
        clientId: _clientId,
        redirectUri: _redirectUri,
      );

      try {
        final tokens = await tokenHandler.exchangeToken(
          modifyPayload: (payload) async {
            payload['grant_type'] = 'authorization_code';
            payload['code'] = uri.queryParameters['code']!;
            payload['code_verifier'] =
                html.window.localStorage['pkce_code_verifier']!;
          },
        );

        final accessToken = tokens['access_token'];
        final idToken = tokens['id_token'];

        setState(() {
          _idToken = idToken;
          _result =
              '✅ Login Successful!\n\nAccess Token: $accessToken\nID Token: $idToken';
        });
      } catch (e) {
        setState(() => _result = '❌ Failed to get token: $e');
      }
    }
  }

  Future<void> _startLogin() async {
    _generateAndStorePkcePair();
    final authorize = OktaIdentityAuthorization(
      oktaIdentityDomain: _oktaIdentityDomain,
      clientId: _clientId,
      redirectUri: _redirectUri,
      // scopes: ['openid', 'profile', 'email'],
    );

    final url = authorize.authorizeApplication((params) {
      params['scope'] = 'openid profile email'; // set scopes here
      params['state'] = 'some-random-state'; // optional but recommended
      params['code_challenge_method'] = 'S256';
      params['code_challenge'] =
          html.window.localStorage['pkce_code_challenge']!;
    });
    html.window.location.href = url.toString();
  }

  Future<void> _logout() async {
    final logoutConsumer = OktaIdentityOidcLogoutConsumer(
      oktaIdentityDomain: _oktaIdentityDomain,
      clientId: _clientId,
      postLogoutRedirectUri: _redirectUri,
    );

    final logoutUrl = await logoutConsumer.logout(
      modify: (params) async {
        if (_idToken != null) {
          params['id_token_hint'] = _idToken!;
        }
      },
    );

    html.window.location.href = logoutUrl.toString();
  }

  Future<void> _samlLogout() async {
    try {
      final samlLogout = OktaIdentitySamlLogoutConsumer(
        oktaIdentityDomain: 'https://dev-07140130.okta.com',
        applicationId: '0oaplfz1eaN0o0DLU5d7', // Your OktaIdentity SAML App ID
        defaultRelayState:
            'http://localhost:8080/logout', // or another post-logout URL
      );

      final logoutUrl = await samlLogout.logout((params) async {
        params['SAMLRequest'] =
            'BASE64_ENCODED_SAML_REQUEST'; // Generate this dynamically or mock it
        // Optionally add:
        // params['Signature'] = 'signature';
        // params['SigAlg'] = 'signature_algorithm_url';
      });

      html.window.location.href = logoutUrl;
    } catch (e) {
      setState(() {
        _result = 'SAML Logout failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OktaIdentity Auth Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Login via PKCE (Authorization Code Flow)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startLogin,
              child: const Text('🔐 Start OktaIdentity Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('🚪 Logout from OktaIdentity'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _samlLogout,
              child: const Text('🔐 SAML Logout'),
            ),

            const SizedBox(height: 20),
            SelectableText(_result ?? 'Idle...'),
          ],
        ),
      ),
    );
  }
}
