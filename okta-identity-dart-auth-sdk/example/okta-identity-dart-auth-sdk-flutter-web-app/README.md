# Okta Identity Dart Auth SDK – Flutter Web Sample App 🧪

This Flutter Web sample app demonstrates **complete integration and testing** of the `okta_identity_dart_auth_sdk`. It verifies the SDK's features through real-world OAuth, OIDC, and SAML flows against a live OktaIdentity dev environment.

📁 **App Location:** `example/web_sample/`  
⚙️ **SDK:** [okta_identity_dart_auth_sdk](https://pub.dev/packages/okta_identity_dart_auth_sdk)  
🧪 **Status:** ✅ All SDK features implemented and verified

---

## 📊 SDK Feature Coverage Table

| Feature Name                     | SDK Method/Class                             | Status   |
|----------------------------------|-----------------------------------------------|----------|
| SDK Base Setup                   | `SDK Initialization`                         | ✅ Done   |
| OIDC Username/Password Login     | `OktaIdentityAuthLoginConsumer`                | ✅ Done   |
| Social Login via IDP             | `OktaIdentitySocialLoginConsumer`              | ✅ Done   |
| OIDC Logout                      | `OktaIdentityOidcLogoutConsumer`               | ✅ Done   |
| SAML Logout                      | `OktaIdentitySamlLogoutConsumer`               | ✅ Done   |
| Token Exchange + Refresh         | `OktaIdentityTokenExchangeConsumer`            | ✅ Done   |
| Token Validation                 | `OktaIdentityTokenValidator`                   | ✅ Done   |
| Global Token Revocation          | `OktaIdentityGlobalTokenRevocationConsumer`    | ✅ Done   |
| User & Profile Management        | `OktaIdentityUserManagement`                   | ✅ Done   |
| MFA Verification                 | `OktaIdentityMultiFactorVerifyConsumer`        | ✅ Done   |
| Authenticator Management         | `OktaIdentityAuthenticatorManagement`          | ✅ Done   |
| OpenID Metadata Discovery        | `OktaIdentityMetadata`                         | ✅ Done   |
| Dynamic Client Registration      | `OktaIdentityDynamicClientRegistration`        | ✅ Done   |
| Authorization URL Builder        | `OktaIdentityAuthorizeApplication`<br>`OktaIdentityAuthorizeEndpoint` | ✅ Done |
| Utility Methods (Link/Delegated) | `OktaIdentityUtilityMethods`                   | ✅ Done   |
| IdP-Initiated SSO Flow           | `OktaIdentityIdpInitiatedSSOFlow`              | ✅ Done   |

---

## 🔍 Feature Deep Dives

### ✅ SDK Base Setup
Initializes the SDK with a reusable singleton containing domain, client ID, and redirect URI. All other SDK classes rely on this configuration.

### ✅ OIDC Username/Password Login
Implements Authorization Code flow with PKCE. Accepts username/password, redirects to OktaIdentity, exchanges code for tokens using `OktaIdentityAuthLoginConsumer`.

### ✅ Social Login via IDP
Redirects to OktaIdentity-configured Identity Providers like Google or Facebook. Uses `OktaIdentitySocialLoginConsumer`.

### ✅ OIDC Logout
Performs OIDC logout by clearing the session and redirecting to the `end_session_endpoint`. Utilizes `OktaIdentityOidcLogoutConsumer`.

### ✅ SAML Logout
Initiates SAML logout via OktaIdentity SP-initiated endpoint. Works with SAML-enabled apps via `OktaIdentitySamlLogoutConsumer`.

### ✅ Token Exchange + Refresh
Uses `OktaIdentityTokenExchangeConsumer` to exchange authorization code or refresh token for new access tokens.

### ✅ Token Validation
Parses and validates JWT access and ID tokens via OpenID metadata (`OktaIdentityTokenValidator`). Checks signature, issuer, audience, and expiration.

### ✅ Global Token Revocation
Invalidates access and refresh tokens via `/revoke`. Uses `OktaIdentityGlobalTokenRevocationConsumer`.

### ✅ User & Profile Management
Fetches and updates OktaIdentity user profiles using the `/userinfo` and `/users/{id}` endpoints through `OktaIdentityUserManagement`.

### ✅ MFA Verification
Verifies enrolled MFA methods (e.g., OTP or push). Validates codes via `OktaIdentityMultiFactorVerifyConsumer`.

### ✅ Authenticator Management
Add, list, and remove authenticators using `OktaIdentityAuthenticatorManagement`. Supports TOTP and WebAuthn.

### ✅ OpenID Metadata Discovery
Retrieves `.well-known/openid-configuration` and parses authorization/token/JWKs endpoints using `OktaIdentityMetadata`.

### ✅ Dynamic Client Registration
Registers a new OAuth application using a payload via `OktaIdentityDynamicClientRegistration`. Returns `client_id`, `client_secret`.

### ✅ Authorization URL Builder
Generates auth URLs using `OktaIdentityAuthorizeApplication` or `OktaIdentityAuthorizeEndpoint` with customizable parameters and scopes.

### ✅ Utility Methods
- **`getSignInLink`** – Builds a sign-in link with optional parameters
- **`acceptDelegatedRequest`** – Accepts delegated access requests via OktaIdentity admin APIs
Available in `OktaIdentityUtilityMethods`.

### ✅ IdP-Initiated SSO Flow
Implements SSO entrypoint from IdP to OktaIdentity via `OktaIdentityIdpInitiatedSSOFlow`. Redirects user with token issuance.

---

## 🧪 QA Summary

- ✅ **100% of SDK Features Covered**
- 🌐 **Tested against real OktaIdentity dev org**
- 📂 **Each feature mapped to a dedicated screen under `lib/screens/`**
- 🧩 **Screens are modular and reusable for production use**
- 🪵 **All HTTP requests and responses are logged in the browser console**
- 🔐 **Secrets/credentials must be rotated in production**

---

## 📘 Developer Notes

- Start the web app with:  
  ```bash
  flutter run -d chrome --web-renderer html
