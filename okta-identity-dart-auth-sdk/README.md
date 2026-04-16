# Okta Identity Dart Auth SDK

Dart SDK for Okta OAuth and OpenID Connect flows in backend and trusted-client integrations.

This package provides helpers for authorization URL generation, token exchange, ROPC login, token validation, logout, metadata discovery, user/admin flows, and IdP-initiated SSO.

## Installation

```yaml
dependencies:
  okta_identity_dart_auth_sdk: ^0.0.6
```

## Recommended Initialization Model

Use `OktaIdentityConfig` plus `OktaIdentityBaseSDK` when you want shared configuration and HTTP client management.

Use the specialized helpers for each flow:

1. `OktaIdentityAuthLoginConsumer`
   Trusted-app username/password flow.
2. `OktaIdentityAuthorization`
   Build `/authorize` URLs for browser or app redirects.
3. `OktaIdentityTokenExchangeConsumer`
   Exchange auth codes or refresh tokens.
4. `OktaIdentityTokenValidator`
   Validate JWTs against Okta JWKS.

## Domain Format Note

The current helpers are not fully normalized on domain format:

- `OktaIdentityConfig` and `OktaIdentityTokenExchangeConsumer` are currently written around a fully-qualified base URL such as `https://dev-12345678.okta.com`
- `OktaIdentityAuthorization` and `OktaIdentityTokenValidator` currently expect the host form `dev-12345678.okta.com`

Use the format required by the helper you instantiate.

## Preferred Backend Initialization

```dart
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

Future<void> main() async {
  final config = OktaIdentityConfig(
    oktaIdentityDomain: 'https://dev-12345678.okta.com',
    clientId: 'your-client-id',
    redirectUri: 'com.example.app:/callback',
    clientSecret: 'your-client-secret',
  );

  final sdk = OktaIdentityBaseSDK(config: config);
  final login = OktaIdentityAuthLoginConsumer(sdk);

  final tokens = await login.signIn((payload) {
    payload['username'] = 'alice@example.com';
    payload['password'] = 'SuperSecret123!';
    payload['scope'] = 'openid profile email offline_access';
  });

  final validator = OktaIdentityTokenValidator(
    oktaIdentityDomain: 'dev-12345678.okta.com',
    clientId: config.clientId,
  );

  final claims = await validator.validateToken(tokens.idToken);
  print(claims['sub']);
}
```

## Browser Redirect Flow

```dart
final auth = OktaIdentityAuthorization(
  clientId: 'your-client-id',
  redirectUri: 'com.example.app:/callback',
  oktaIdentityDomain: 'dev-12345678.okta.com',
);

final authorizeUrl = auth.authorizeApplication((params) {
  params['scope'] = 'openid profile email offline_access';
  params['state'] = 'random-state';
});

print(authorizeUrl);
```

## Token Exchange

```dart
final exchange = OktaIdentityTokenExchangeConsumer(
  oktaIdentityDomain: 'https://dev-12345678.okta.com',
  clientId: 'your-client-id',
  redirectUri: 'com.example.app:/callback',
  clientSecret: 'your-client-secret',
);

final tokens = await exchange.exchangeToken(
  modifyPayload: (payload) async {
    payload['grant_type'] = 'authorization_code';
    payload['code'] = 'authorization-code';
  },
);

print(tokens['access_token']);
```

## Security Guidance

- Prefer Authorization Code plus PKCE for public clients.
- Reserve client secrets and ROPC flows for trusted server-side applications.
- Always validate ID tokens before using claims for sensitive operations.
- Normalize your Okta domain carefully per helper until the APIs are fully consistent.

## Examples

See the `example/` directory for current sample apps and integration references.
