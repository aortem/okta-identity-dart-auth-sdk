import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaUserManagementScreen extends StatefulWidget {
  const OktaUserManagementScreen({super.key});

  @override
  State<OktaUserManagementScreen> createState() =>
      _OktaUserManagementScreenState();
}

class _OktaUserManagementScreenState extends State<OktaUserManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;
  String _status = '';

  // 🧠 Use your SDK
  final _oktaConsumer = OktaUserManagementConsumer(
    oktaDomain: 'https://dev-123456.okta.com', // ✅ Replace
    apiToken: 'your_api_token_here', // ✅ Replace
  );

  Future<void> _signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _status = '';
    });

    try {
      final user = await _oktaConsumer.signUp(
        buildPayload: (builder) async {
          builder.setEmail(_emailController.text);
          builder.setLogin(_emailController.text); // same as email
          builder.setFirstName(_firstNameController.text);
          builder.setLastName(_lastNameController.text);
          builder.setPassword(_passwordController.text);
        },
      );

      setState(() {
        _status = '✅ User created: ${user['id']}';
      });
    } on Exception catch (e) {
      setState(() => _status = '❌ API Error: $e');
    } catch (e) {
      setState(() => _status = '❌ Unknown error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Okta Sign Up (via SDK)')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUpUser,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            Text(_status, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
