import 'package:flutter/material.dart';
import 'login_dialog.dart';
import 'register_dialog.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => showLoginDialog(context),
              child: const Text("🔓 Log in"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showRegisterDialog(context),
              child: const Text("✍️ Register"),
            ),
          ],
        ),
      ),
    );
  }
}
