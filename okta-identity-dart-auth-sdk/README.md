# Okta Identity Dart Auth SDK

## Overview

The **Okta Identity Dart Auth SDK** provides a lightweight, idiomatic Dart/Flutter toolkit for implementing Okta OIDC authentication flows. It helps you:

* Build `/authorize` requests (PKCE).
* Exchange authorization codes and refresh tokens.
* Perform **Resource Owner Password** (ROPC) logins when appropriate.
* Validate ID tokens (JWKS, signature & claims).
* Handle common Okta/OIDC errors in a consistent way.

This package wraps the Okta OAuth2/OpenID Connect endpoints and includes helpers for PKCE, token handling, and validation.

## Features

* **Authorization Code + PKCE**: Generate a PKCE pair, redirect to Okta, and exchange the returned code for tokens.
* **ROPC Login**: First-party/password flows for trusted apps (server-side or enterprise scenarios).
* **Token Exchange & Refresh**: Swap an auth code for tokens, refresh access/ID tokens.
* **ID Token Validation**: Validate signature and claims against Okta’s JWKS.
* **Typed Errors**: Consistent exceptions for request and auth failures.

## Getting Started

* Dart SDK **3.8.x** (or compatible Flutter).
* An **Okta Developer Org** and an **OIDC app integration** (Client ID, Redirect URI, Issuer/Domain).
* (Optional) A **client secret** if your app is *confidential* (server-side). Don’t embed client secrets in public/mobile apps.

## Installation

Add via Flutter:

```bash
flutter pub add okta_identity_dart_auth_sdk
```

Or add to `pubspec.yaml`:

```yaml
dependencies:
  okta_identity_dart_auth_sdk: ^0.0.1
```

> **Note:** Version may vary. Check the latest on pub.dev.

## Usage

Import the package:

```dart
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
```

### 1) Configure the SDK

Create a base configuration with your Okta details:

```dart
// Create the Okta config for your app/org
final config = OktaConfig(
  oktaDomain: 'dev-12345678.okta.com',  // issuer host (no https://)
  clientId: 'YOUR_CLIENT_ID',
  redirectUri: 'https://yourapp.example.com/callback',
  scope: ['openid', 'profile', 'email', 'offline_access'],
  // clientSecret: 'ONLY_FOR_CONFIDENTIAL_APPS', // optional
);

// Instantiate the base SDK
final okta = OktaBaseSDK(config);
```

> `oktaDomain` should be the hostname portion of your issuer (e.g. `dev-xxxxx.okta.com`). Your Okta app’s **Redirect URI** must exactly match what you pass here.

### 2) Authorization Code + PKCE (recommended)

**a. Create the PKCE pair and build the authorize URL**

```dart
// Generate PKCE
final pkce = await okta.utils.generatePkcePair();
// pkce.codeVerifier, pkce.codeChallenge

// Build the /authorize URL for your login button/webview
final auth = OktaAuthorization(
  oktaDomain: config.oktaDomain,
  clientId: config.clientId,
  redirectUri: config.redirectUri,
);

// Construct an authorization URL (include scopes, state, and PKCE)
final authorizeUrl = auth.authorizeUrl(
  scopes: config.scope,
  state: 'random-state-123',
  codeChallenge: pkce.codeChallenge,
  codeChallengeMethod: 'S256',
);

// → Open `authorizeUrl` in a browser/webview.
// → After consent/login, Okta will redirect back to `redirectUri` with `?code=...&state=...`
```

**b. Exchange the authorization code for tokens**

```dart
// When your redirect/callback handler receives `code`:
final tokenExchange = OktaTokenExchangeConsumer(okta);

final tokens = await tokenExchange.exchangeToken((payload) async {
  payload['grant_type'] = 'authorization_code';
  payload['code'] = receivedAuthCode;
  payload['redirect_uri'] = config.redirectUri;
  payload['code_verifier'] = pkce.codeVerifier;
});

// tokens.accessToken, tokens.idToken, tokens.refreshToken (if requested)
```

**c. Refresh tokens later**

```dart
final refreshed = await tokenExchange.exchangeToken((payload) async {
  payload['grant_type'] = 'refresh_token';
  payload['refresh_token'] = tokens.refreshToken!;
});
```

### 3) Validate an ID Token

```dart
final validator = OktaTokenValidator(okta);

// Throws if invalid signature/claims; returns decoded payload on success.
final payload = await validator.validateToken(tokens.idToken);

// Optionally validate custom claims too:
validator.validateClaims(payload, expectedIssuer: 'https://${config.oktaDomain}/oauth2/default');
```

### 4) ROPC (Resource Owner Password) login (optional)

Use for first-party, trusted apps only (typically server-side or enterprise environments). Not recommended for public/mobile clients.

```dart
final ropc = OktaAuthLoginConsumer(okta);

final ropcTokens = await ropc.signIn((payload) {
  payload['username'] = 'user@example.com';
  payload['password'] = 'super-secret';
  payload['scope'] = 'openid profile email offline_access';
});

// ropcTokens.accessToken / ropcTokens.idToken / ropcTokens.refreshToken
```

### 5) Error handling

Most network and OAuth errors are surfaced as typed exceptions:

```dart
try {
  final payload = await validator.validateToken(tokens.idToken);
} on OktaTokenValidationException catch (e) {
  // Signature/claims invalid, expired, wrong audience/issuer, etc.
} on OktaRequestException catch (e) {
  // HTTP/network issues or non-2xx responses from Okta
} catch (e) {
  // Other errors
}
```

## Security Notes

* **Never embed client secrets** in mobile or browser apps.
* Prefer **Authorization Code + PKCE** for public clients.
* Ensure your **Redirect URI** matches your Okta app config exactly.
* Always **validate** ID tokens server-side for sensitive operations.

## Example Apps

The repository includes a Flutter Web example showing authorization, token exchange, refresh, and validation. Check the `example/` folder for runnable samples.

## API Surface (at a glance)

* `OktaConfig` – Domain, clientId, redirectUri, scopes, optional clientSecret.
* `OktaBaseSDK` – Root container that wires up helpers and utilities.
* `OktaAuthorization` – Builds `/authorize` URLs (PKCE).
* `OktaTokenExchangeConsumer` – Exchanges codes and refresh tokens.
* `OktaAuthLoginConsumer` – ROPC login.
* `OktaTokenValidator` – Fetches JWKS and validates ID tokens.
* Exceptions in `exception/` – Request, validation, and auth-specific errors.
* Utilities in `utils/` – PKCE helpers and common HTTP plumbing.

## License

MIT

---

Want me to drop this straight into your repo as `README.md` and tweak the snippets (e.g., method names/params) to match your preferred public API surface?
