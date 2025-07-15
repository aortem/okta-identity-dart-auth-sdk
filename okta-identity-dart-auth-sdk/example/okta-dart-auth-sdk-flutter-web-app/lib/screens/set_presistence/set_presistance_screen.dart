import 'dart:developer';

import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';
import 'package:flutter/material.dart';

import 'okta_identity_presistance.dart';

class PersistenceSelectorDropdown extends StatefulWidget {
  const PersistenceSelectorDropdown({super.key});

  @override
  State<PersistenceSelectorDropdown> createState() =>
      _PersistenceSelectorDropdownState();
}

class _PersistenceSelectorDropdownState
    extends State<PersistenceSelectorDropdown> {
  String? _selectedPersistence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: DropdownButton<String>(
        value: _selectedPersistence,
        hint: const Text('Choose Persistence Option'),
        onChanged: (String? newValue) async {
          setState(() {
            _selectedPersistence = newValue;
          });
          if (newValue != null) {
            if (_selectedPersistence != null) {
              try {
                await okta -
                    identityApp.okta -
                    identityAuth?.setPresistanceMethod(
                        _selectedPersistence!, 'firebasdartadminauthsdk');
                //  log("response of pressitance $response");
              } catch (e) {
                log("response of pressitance $e");
              }
            }
          }
        },
        items: const [
          DropdownMenuItem(
            value: okta - identityPersistence.local,
            child: Text('Local'),
          ),
          DropdownMenuItem(
            value: okta - identityPersistence.session,
            child: Text('Session'),
          ),
          DropdownMenuItem(
            value: okta - identityPersistence.none,
            child: Text('None'),
          ),
        ],
      ),
    ));
  }
}
