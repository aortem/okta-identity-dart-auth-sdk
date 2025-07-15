# okta-identity-dart-sample-app

## Description

A sample app to showcase the process of installing, setting up and using the okta_identity_dart_auth_sdk

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)

## Installation

- Add the absolute path of the okta_identity_dart_auth_sdk to the sample app's pubspec.yaml file
  ```yaml
  dependencies:
  okta_identity_dart_auth_sdk:
    path: /Users/user/Documents/GitLab/okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk
  ```

## Usage

    Depending on the platform okta_identity_dart_auth_sdk can be initialized via three methods

**Web:**
For Web we use Enviroment Variable

```
import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

    void main() async
    {

        okta-identityApp.initializeAppWithEnvironmentVariables(apiKey:'api_key',projectId: 'project_id',);

        okta-identityApp.instance.getAuth();

        runApp(const MyApp());
    }

```

- Import the okta_identity_dart_auth_sdk and the material app
  ```
  import 'package:flutter/material.dart';
  import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
  ```
- In the main function call the 'okta-identityApp.initializeAppWithEnvironmentVariables' and pass in your api key and project id

  ```
    okta-identityApp.initializeAppWithEnvironmentVariables(apiKey:'api_key',projectId: 'project_id',);
  ```

- Aftwards call the 'okta-identityApp.instance.getAuth()'
  ```
    okta-identityApp.instance.getAuth();
  ```
- Then call the 'runApp(const MyApp())' method

  ```
      runApp(const MyApp())

  ```

**Mobile:**
For mobile we can use either [Service Account](#serviceaccount) or [Service account impersonation](#ServiceAccountImpersonation)

## ServiceAccount

    ```
    import 'package:flutter/material.dart';
    import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

    void main() async
    {
        okta-identityApp.initializeAppWithServiceAccount(serviceAccountKeyFilePath: 'path_to_json_file');

        okta-identityApp.instance.getAuth();
        runApp(const MyApp());
    }
    ```

- Import the okta_identity_dart_auth_sdk and the material app

  ```
  import 'package:flutter/material.dart';
  import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
  ```

- In the main function call the 'okta-identityApp.initializeAppWithServiceAccount' function and pass the path to your the json file
  ```
   okta-identityApp.initializeAppWithServiceAccount(serviceAccountKeyFilePath: 'path_to_json_file');
  ```
- Aftwards call the 'okta-identityApp.instance.getAuth()'
  ```
    okta-identityApp.instance.getAuth();
  ```
- Then call the 'runApp(const MyApp())' method

  ```
      runApp(const MyApp())

  ```

## ServiceAccountImpersonation

    ```
    import 'package:flutter/material.dart';
    import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

    void main() async
    {
        okta-identityApp.initializeAppWithServiceAccountImpersonation(serviceAccountEmail: service_account_email, userEmail: user_email)

        okta-identityApp.instance.getAuth();
        runApp(const MyApp());
    }
    ```

- Import the okta_identity_dart_auth_sdk and the material app

  ```
  import 'package:flutter/material.dart';
  import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
  ```

- In the main function call the 'okta-identityApp.initializeAppWithServiceAccountImpersonation' function and pass the service_account_email and user_email
  ```
    okta-identityApp.initializeAppWithServiceAccountImpersonation(serviceAccountEmail: serviceAccountEmail,userEmail:userEmail,)
  ```
- Aftwards call the 'okta-identityApp.instance.getAuth()'
  ```
    okta-identityApp.instance.getAuth();
  ```
- Then call the 'runApp(const MyApp())' method

  ```
      runApp(const MyApp())

  ```
