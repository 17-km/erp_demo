import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> showRegisterDialog(BuildContext context) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Register"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await supabase.auth.signUp(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  emailRedirectTo: 'erpdemo://auth-callback?flow=signup',
                );

                if (!context.mounted) return;

                final user = response.user;

                if (user != null) {
                  if ((user.userMetadata ?? {}).isEmpty &&
                      (user.identities ?? []).isEmpty) {
                    // Email already registered
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text("Registration failed"),
                            content: Text(
                              "This email is already registered. Please log in.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                  } else {
                    // ✅ sukces
                    // Navigator.pop(context); // zamykamy okno rejestracji
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Registration Successful"),
                            content: const Text(
                              "✅ Your account has been created.\nPlease confirm your email before logging in.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                  }
                }
              } on AuthApiException catch (e) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Registration failed"),
                        content: Text(e.message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                );
              } catch (e) {
                // Spróbuj złapać szczegółowo Postgrest lub inne API błędy
                String message = "Something went wrong. Please try again.";
                if (e.toString().contains("statusCode: 422")) {
                  message =
                      "Password too short or invalid input. Please fix and try again.";
                }
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Unexpected error"),
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                );
              }
            },
            child: const Text("Register"),
          ),
        ],
      );
    },
  );
}
