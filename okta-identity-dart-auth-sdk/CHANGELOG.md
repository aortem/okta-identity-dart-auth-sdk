# Changelog

## [0.0.6]
### Added

- Example index documentation under `example/README.md` for the current sample-app directories.

### Changed

- Refreshed the package README to a backend-first structure with clearer initialization guidance and domain-format notes.
- Bumped the package Dart SDK floor to `3.11.4`.
- Bumped the Flutter web example Dart SDK floor to `3.11.4`.
- Updated backend validation CI to enforce the `3.11.4` minimum SDK version.
- Corrected frontend CI paths to the current hyphenated Okta example-app directory names.

### Notes

- No API-breaking changes are intended in this release-prep update.

## [0.0.5]
### Updated

- Bump Dart version to 3.10.3

## [0.0.4]
### Changed

- Updated Test folder with revised naming conventions

## [0.0.3]
### Changed

- Renamed all internal modules from `aortem_okta_issue_*` → `okta_issue_*` for consistency.
- Simplified SDK entry point: `bin/main.dart` now uses a **single consolidated import** instead of multiple file-level imports.
- Updated example Flutter app (`/example/lib/main.dart`) to reflect new import structure.
- Standardized file naming across the SDK for clarity and maintainability.

### Updated

- Bump Dart SDK Version

### Breaking

- Direct imports of `aortem_okta_issue_*` files will no longer work.

  - ✅ Developers should now import only via:

    ```dart
    import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
    ```
## [0.0.2]
### Added
- New quick-start and usage examples in `/example`.
- Optional configuration notes in README for common setups.
- Additional unit tests covering edge cases.

### Changed
- Improved error handling around token expiry and invalid credentials.
- Clarified API docs and inline comments for authentication flows.
- Minor internal refactors and formatting (`dart format`, lints).

### Removed
- Deprecated helpers and unused code paths.

## [0.0.1]
- Added support for token refresh flow in `OktaIdentityClient`.
- Improved error handling for invalid/expired tokens.
- Updated API docs for authentication methods.
- Minor refactors and code formatting updates.

## [0.0.2-pre]
- Initial pre-release version of the okta-identity Dart Auth SDK.

