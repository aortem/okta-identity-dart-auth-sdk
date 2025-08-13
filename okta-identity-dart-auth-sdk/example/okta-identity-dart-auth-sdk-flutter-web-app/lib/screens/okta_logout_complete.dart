import 'package:flutter/material.dart';

class LogoutCompleteScreen extends StatelessWidget {
  const LogoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "✅ You have been logged out successfully.",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
