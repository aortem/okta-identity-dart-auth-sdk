# Okta Identity Dart Auth SDK – Flutter Web Sample App 🧪

This Flutter Web sample app demonstrates **complete integration and testing** of the `okta_identity_dart_auth_sdk`. It verifies the SDK's features through real-world OAuth, OIDC, and SAML flows against a live Okta dev environment.

📁 **App Location:** `example/web_sample/`  
⚙️ **SDK:** [okta_identity_dart_auth_sdk](https://pub.dev/packages/okta_identity_dart_auth_sdk)  
🧪 **Status:** ✅ All SDK features implemented and verified

---

## 📊 SDK Feature Coverage Table

| Feature Name                     | SDK Method/Class                             | Status   |
|----------------------------------|-----------------------------------------------|----------|
| SDK Base Setup                   | `SDK Initialization`                         | ✅ Done   |
| OIDC Username/Password Login     | `AortemOktaAuthLoginConsumer`                | ✅ Done   |
| Social Login via IDP             | `AortemOktaSocialLoginConsumer`              | ✅ Done   |
| OIDC Logout                      | `AortemOktaOidcLogoutConsumer`               | ✅ Done   |
| SAML Logout                      | `AortemOktaSamlLogoutConsumer`               | ✅ Done   |
| Token Exchange + Refresh         | `AortemOktaTokenExchangeConsumer`            | ✅ Done   |
| Token Validation                 | `AortemOktaTokenValidator`                   | ✅ Done   |
| Global Token Revocation          | `AortemOktaGlobalTokenRevocationConsumer`    | ✅ Done   |
| User & Profile Management        | `AortemOktaUserManagement`                   | ✅ Done   |
| MFA Verification                 | `AortemOktaMultiFactorVerifyConsumer`        | ✅ Done   |
| Authenticator Management         | `AortemOktaAuthenticatorManagement`          | ✅ Done   |
| OpenID Metadata Discovery        | `AortemOktaMetadata`                         | ✅ Done   |
| Dynamic Client Registration      | `AortemOktaDynamicClientRegistration`        | ✅ Done   |
| Authorization URL Builder        | `AortemOktaAuthorizeApplication`<br>`AortemOktaAuthorizeEndpoint` | ✅ Done |
| Utility Methods (Link/Delegated) | `AortemOktaUtilityMethods`                   | ✅ Done   |
| IdP-Initiated SSO Flow           | `AortemOktaIdpInitiatedSSOFlow`              | ✅ Done   |

---

## 🔍 Feature Deep Dives

### ✅ SDK Base Setup
Initializes the SDK with a reusable singleton containing domain, client ID, and redirect URI. All other SDK classes rely on this configuration.

### ✅ OIDC Username/Password Login
Implements Authorization Code flow with PKCE. Accepts username/password, redirects to Okta, exchanges code for tokens using `AortemOktaAuthLoginConsumer`.

### ✅ Social Login via IDP
Redirects to Okta-configured Identity Providers like Google or Facebook. Uses `AortemOktaSocialLoginConsumer`.

### ✅ OIDC Logout
Performs OIDC logout by clearing the session and redirecting to the `end_session_endpoint`. Utilizes `AortemOktaOidcLogoutConsumer`.

### ✅ SAML Logout
Initiates SAML logout via Okta SP-initiated endpoint. Works with SAML-enabled apps via `AortemOktaSamlLogoutConsumer`.

### ✅ Token Exchange + Refresh
Uses `AortemOktaTokenExchangeConsumer` to exchange authorization code or refresh token for new access tokens.

### ✅ Token Validation
Parses and validates JWT access and ID tokens via OpenID metadata (`AortemOktaTokenValidator`). Checks signature, issuer, audience, and expiration.

### ✅ Global Token Revocation
Invalidates access and refresh tokens via `/revoke`. Uses `AortemOktaGlobalTokenRevocationConsumer`.

### ✅ User & Profile Management
Fetches and updates Okta user profiles using the `/userinfo` and `/users/{id}` endpoints through `AortemOktaUserManagement`.

### ✅ MFA Verification
Verifies enrolled MFA methods (e.g., OTP or push). Validates codes via `AortemOktaMultiFactorVerifyConsumer`.

### ✅ Authenticator Management
Add, list, and remove authenticators using `AortemOktaAuthenticatorManagement`. Supports TOTP and WebAuthn.

### ✅ OpenID Metadata Discovery
Retrieves `.well-known/openid-configuration` and parses authorization/token/JWKs endpoints using `AortemOktaMetadata`.

### ✅ Dynamic Client Registration
Registers a new OAuth application using a payload via `AortemOktaDynamicClientRegistration`. Returns `client_id`, `client_secret`.

### ✅ Authorization URL Builder
Generates auth URLs using `AortemOktaAuthorizeApplication` or `AortemOktaAuthorizeEndpoint` with customizable parameters and scopes.

### ✅ Utility Methods
- **`getSignInLink`** – Builds a sign-in link with optional parameters
- **`acceptDelegatedRequest`** – Accepts delegated access requests via Okta admin APIs
Available in `AortemOktaUtilityMethods`.

### ✅ IdP-Initiated SSO Flow
Implements SSO entrypoint from IdP to Okta via `AortemOktaIdpInitiatedSSOFlow`. Redirects user with token issuance.

---

## 🧪 QA Summary

- ✅ **100% of SDK Features Covered**
- 🌐 **Tested against real Okta dev org**
- 📂 **Each feature mapped to a dedicated screen under `lib/screens/`**
- 🧩 **Screens are modular and reusable for production use**
- 🪵 **All HTTP requests and responses are logged in the browser console**
- 🔐 **Secrets/credentials must be rotated in production**

---

## 📘 Developer Notes

- Start the web app with:  
  ```bash
  flutter run -d chrome --web-renderer html
