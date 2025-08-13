<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/aortem/logos/main/Aortem-logo-small.png" />
    <img align="center" alt="Aortem Logo" src="https://raw.githubusercontent.com/aortem/logos/main/Aortem-logo-small.png" />
  </picture>
</p>

<!-- x-hide-in-docs-end -->

<p align="center" class="github-badges">
  <!-- GitHub Tag Badge -->
  <a href="https://github.com/aortem/okta-identity-dart-auth-sdk/tags">
    <img alt="GitHub Tag" src="https://img.shields.io/github/v/tag/aortem/okta-identity-dart-auth-sdk?style=for-the-badge" />
  </a>
  <!-- Dart-Specific Badges -->
  <a href="https://pub.dev/packages/okta_identity_dart_auth_sdk">
    <img alt="Pub Version" src="https://img.shields.io/pub/v/okta_identity_dart_auth_sdk.svg?style=for-the-badge" />
  </a>
  <a href="https://dart.dev/">
    <img alt="Built with Dart" src="https://img.shields.io/badge/Built%20with-Dart-blue.svg?style=for-the-badge" />
  </a>
<!-- x-hide-in-docs-start -->

# Okta Identity Dart Auth SDK

Okta Identity Dart Auth SDK is designed to provide select out-of-the-box Okta features in Dart. Both low-level and high-level abstractions are provided.

## Features

This implementation does not yet support all functionalities of Okta. Here is a list of functionalities with the current support status (based on the code in this repo):

| #  | Method / Area                                                                  | Supported |
| -- | ------------------------------------------------------------------------------ | :-------: |
| 1  | Constructors & Base SDK Setup (`OktaIdentityBaseSDK`)                          |     ✅     |
| 2  | Configuration & HTTP Client (domain, clientId/secret)                          |     ✅     |
| 3  | Username/Password Login (ROPC) `OktaIdentityAuthLoginConsumer`                 |     ✅     |
| 4  | Social / Federated Login (Token Exchange) `OktaIdentitySocialLoginConsumer`    |     ✅     |
| 5  | OIDC Logout                                                                    |     ✅     |
| 6  | SAML Logout                                                                    |     ✅     |
| 7  | Authorization URL & Code Exchange `OktaIdentityAuthorization`                  |     ✅     |
| 8  | Token Validation (JWT + JWKS rotation) `OktaIdentityTokenValidator`            |     ✅     |
| 9  | Global Token Revocation (RFC 7009) `OktaIdentityTokenRevocationPayloadBuilder` |     ✅     |
| 10 | IdP-Initiated SSO URL Builder `OktaIdentityIdpInitiatedSSO`                    |     ✅     |
| 11 | Dynamic Client Registration                                                    |     ✅     |
| 12 | User Management APIs                                                           |     ✅     |
| 13 | MFA / Authenticator Verification                                               |     ✅     |
| 14 | Authenticator Management                                                       |     ✅     |
| 15 | Metadata Retrieval / Discovery                                                 |     ✅     |
| 16 | Utility Methods & Helpers                                                      |     ✅     |
| 17 | Exceptions (config, API, validation, missing token)                            |     ✅     |

> Notes:
>
> * Token validation uses `jwt_generator` and fetches signing keys from the Okta JWKS endpoint.
> * The base SDK centralizes config (Okta domain, client credentials, redirect URI) and HTTP client lifecycle.
> * Social/federated login and SSO helpers follow Okta OIDC/OAuth patterns.

## Available Versions

Okta Identity Dart Auth SDK is available in two versions to cater to different needs:

1. **Main – Stable Version**: Usually one release a month. This version aims to maintain stability without introducing breaking changes.
2. **Sample Apps – Frontend Versions**: Example apps are provided (Flutter/Dart web, etc.) to help you integrate your frontend with a Dart backend. New features are first exercised in the sample apps before being released to the mainline branch. Use as guidance only.

## Documentation

For detailed guides, API references, and example projects, visit our **Okta Identity Dart Auth SDK Documentation** (replace with your docs URL):
`https://sdks.aortem.io/okta-identity-dart-auth-sdk`

Helpful Okta references for implementers:

* Okta Identity Providers (IdPs) API
* Okta OpenID Connect & OAuth 2.0 docs
* Okta JWKS / token validation docs

## Examples

Explore the `/example` directory in this repository to find sample applications demonstrating Okta Identity Dart Auth SDK capabilities in real-world scenarios (Flutter web/desktop placeholders and a Dart web sample are included).

## Contributing

We welcome contributions of all forms from the community! If you're interested in helping improve Okta Identity Dart Auth SDK, please fork the repository and submit your pull requests. For more details, check out our [CONTRIBUTING.md](CONTRIBUTING.md) guide. Our team will review your pull request. Once approved, we will integrate your changes into our primary repository and push the mirrored changes on the main GitHub branch.

## Support

For support across all Aortem open-source products, including this SDK, visit our [Support Page](https://aortem.io/support).

## Licensing

The **Okta Identity Dart Auth SDK** is licensed under a dual-license approach:

1. **BSD-3 License**:

   * Applies to all packages and libraries in the SDK.
   * Allows use, modification, and redistribution, provided that credit is given and compliance with the BSD-3 terms is maintained.
   * Permits usage in open-source projects, applications, and private deployments.

2. **Enhanced License Version 2 (ELv2)**:

   * Applies to all use cases where the SDK or its derivatives are offered as part of a **cloud service**.
   * This ensures that the SDK cannot be directly used by cloud providers to offer competing services without explicit permission.
   * Example restricted use cases:

     * Including the SDK in a hosted SaaS authentication platform.
     * Offering the SDK as a component of a managed cloud service.

### **Summary**

* You are free to use the SDK in your applications, including open-source and commercial projects, as long as the SDK is not directly offered as part of a third-party cloud service.
* For details, refer to the [LICENSE](LICENSE.md) file.

## Enhance with Okta Identity Dart Auth SDK

We hope the Okta Identity Dart Auth SDK helps you efficiently build and scale your server-side applications. Join our growing community and start contributing to the ecosystem today!
