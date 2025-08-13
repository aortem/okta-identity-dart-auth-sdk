import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/IdpSsoTestScreen.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/OktaIdentityAuthorization.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/OktaIdentityDynamicClientRegistration.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_auth_login.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_auth_management.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_logout_complete.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_logout_screen.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_mfa_login.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_social_login.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_token_exchange.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_token_revocation.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_token_validation.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_user_management.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_utility_screen.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/oktametadata_screen.dart';
import 'package:okta_identity_dart_auth_sdk_flutter_web_app/screens/okta_base_sdk_screen.dart';

void main() {
  runApp(const OktaIdentitySampleApp());
}

class OktaIdentitySampleApp extends StatelessWidget {
  const OktaIdentitySampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OktaIdentity Dart Auth Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OktaIdentityHomePage(),
        '/logout-complete': (context) => const LogoutCompleteScreen(),
      },
      // home: const OktaIdentityHomePage(),
    );
  }
}

class OktaIdentityHomePage extends StatelessWidget {
  const OktaIdentityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OktaIdentity Dart Auth Web Sample")),
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
                title: "OktaIdentityAuthLogin – Username/Password",
                description:
                    "Authenticate using username & password with consumer pattern.",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaIdentityAuthLoginScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityBaseSDKSetup",
                description: "Base SDK Setup and Configuration",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaIdentityBaseSDKScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentitySocialLogin(Social Sign-In)",
                description:
                    "Implement Social Sign-In Flow via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaIdentitySocialLoginScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityOidcLogout",
                description: "OIDC Logout Flow via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaIdentityLogoutScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityTokenValidation",
                description: "JWT Token Validation",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TokenValidationScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityGlobalTokenRevocation",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OktaIdentityTokenRevocationScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityUserManagement",
                description: "User and Profile Management via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OktaIdentityUserManagementScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityMultiFactorVerify",
                description: "Multi-Factor Authentication via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OktaIdentityLoginPage()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityAuthenticatorManagement",
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
                title: "OktaIdentityMetadata",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OktaIdentityMetadataScreen(),
                    ),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityIdpInitiatedSSO",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IdpSsoTestScreen()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityDynamicClientRegistration",
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
                title: "OktaIdentityAuthorization",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OktaIdentityAuthScreen()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityTokenExchange",
                description: "Token Exchange and Refresh via Consumer Pattern",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TokenExchangeScreen()),
                  );
                },
              ),
              FeatureButton(
                title: "OktaIdentityUtilityMethods",
                description: "",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OktaIdentityUtilityScreen(),
                    ),
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
