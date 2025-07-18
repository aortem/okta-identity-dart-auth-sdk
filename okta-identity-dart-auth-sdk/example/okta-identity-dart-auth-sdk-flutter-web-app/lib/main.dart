import 'package:flutter/material.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/IdpSsoTestScreen.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/OktaAuthorization.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/OktaDynamicClientRegistration.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_auth_login.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_auth_management.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_logout_complete.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_logout_screen.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_mfa_login.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_social_login.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_token_revocation.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_token_validation.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/okta_user_management.dart';
import 'package:okta-identity-dart-auth-sdk-flutter-web-app/screens/oktametadata_screen.dart';

void main() {
  runApp(const OktaSampleApp());
}

class OktaSampleApp extends StatelessWidget {
  const OktaSampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okta Dart Auth Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OktaHomePage(),
        '/logout-complete': (context) => const LogoutCompleteScreen(),
      },
      // home: const OktaHomePage(),
    );
  }
}

class OktaHomePage extends StatelessWidget {
  const OktaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Okta Dart Auth Web Sample")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SDK Features :',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FeatureButton(
                title: "OktaAuthLogin – Username/Password",
                description:
                    "Authenticate using username & password with consumer pattern.",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaAuthLoginScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaSocialLogin(Social Sign-In)",
                description:
                    "Implement Social Sign-In Flow via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaSocialLoginScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaOidcLogout",
                description: "OIDC Logout Flow via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OktaLogoutScreen()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaTokenValidation",
                description: "JWT Token Validation",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TokenValidation(token: '<JWT_TOKEN>'),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaGlobalTokenRevocation",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaTokenRevocationScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaUserManagement",
                description: "User and Profile Management via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OktaUserManagementScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaMultiFactorVerify",
                description: "Multi-Factor Authentication via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OktaLoginPage()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaAuthenticatorManagement",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthenticatorTestScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaMetadata",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OktaMetadataScreen()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdpInitiatedSSO",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IdpSsoTestScreen()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaDynamicClientRegistration",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DynamicClientRegistrationScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaAuthorization",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OktaAuthScreen()),
                  );
                },
              ),
              // Add more FeatureButton widgets as needed for other features
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  const FeatureButton({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }
}
