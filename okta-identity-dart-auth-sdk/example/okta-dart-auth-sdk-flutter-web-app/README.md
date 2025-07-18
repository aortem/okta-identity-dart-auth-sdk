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

        OktaIdentityApp.initializeAppWithEnvironmentVariables(apiKey:'api_key',projectId: 'project_id',);

        OktaIdentityApp.instance.getAuth();

        runApp(const MyApp());
    }

```

- Import the okta_identity_dart_auth_sdk and the material app
  ```
  import 'package:flutter/material.dart';
  import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
  ```
- In the main function call the 'OktaIdentityApp.initializeAppWithEnvironmentVariables' and pass in your api key and project id

  ```
    OktaIdentityApp.initializeAppWithEnvironmentVariables(apiKey:'api_key',projectId: 'project_id',);
  ```

- Aftwards call the 'OktaIdentityApp.instance.getAuth()'
  ```
    OktaIdentityApp.instance.getAuth();
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
        OktaIdentityApp.initializeAppWithServiceAccount(serviceAccountKeyFilePath: 'path_to_json_file');

        OktaIdentityApp.instance.getAuth();
        runApp(const MyApp());
    }
    ```

- Import the okta_identity_dart_auth_sdk and the material app

  ```
  import 'package:flutter/material.dart';
  import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
  ```

- In the main function call the 'OktaIdentityApp.initializeAppWithServiceAccount' function and pass the path to your the json file
  ```
   OktaIdentityApp.initializeAppWithServiceAccount(serviceAccountKeyFilePath: 'path_to_json_file');
  ```
- Aftwards call the 'OktaIdentityApp.instance.getAuth()'
  ```
    OktaIdentityApp.instance.getAuth();
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
        OktaIdentityApp.initializeAppWithServiceAccountImpersonation(serviceAccountEmail: service_account_email, userEmail: user_email)

        OktaIdentityApp.instance.getAuth();
        runApp(const MyApp());
    }
    ```

- Import the okta_identity_dart_auth_sdk and the material app

  ```
  import 'package:flutter/material.dart';
  import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
  ```

- In the main function call the 'OktaIdentityApp.initializeAppWithServiceAccountImpersonation' function and pass the service_account_email and user_email
  ```
    OktaIdentityApp.initializeAppWithServiceAccountImpersonation(serviceAccountEmail: serviceAccountEmail,userEmail:userEmail,)
  ```
- Aftwards call the 'OktaIdentityApp.instance.getAuth()'
  ```
    OktaIdentityApp.instance.getAuth();
  ```
- Then call the 'runApp(const MyApp())' method

  ```
      runApp(const MyApp())

  ```
