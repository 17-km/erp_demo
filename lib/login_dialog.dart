import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> showLoginDialog(BuildContext context) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Login"),
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
          // ElevatedButton(
          //   onPressed: () async {
          //     try {
          //       final response = await supabase.auth.signInWithPassword(
          //         email: emailController.text.trim(),
          //         password: passwordController.text.trim(),
          //       );

          //       if (response.user != null) {
          //         Navigator.pop(context); // zamyka dialog
          //         Navigator.pushReplacementNamed(
          //           context,
          //           '/home',
          //         ); // przejście do HomePage
          //       } else {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Login failed. Please try again.'),
          //           ),
          //         );
          //       }
          //     } on AuthApiException catch (e) {
          //       ScaffoldMessenger.of(
          //         context,
          //       ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
          //     } catch (e) {
          //       ScaffoldMessenger.of(
          //         context,
          //       ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
          //     }
          //   },
          //   child: const Text("Login"),
          // ),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await supabase.auth.signInWithPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                if (!context.mounted) return;

                if (response.user != null) {
                  Navigator.pop(context); // zamyka dialog
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                  ); // przejście do HomePage
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login failed. Please try again.'),
                    ),
                  );
                }
              } on AuthApiException catch (e) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Login failed"),
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
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Unexpected error"),
                        content: Text(e.toString()),
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
            child: const Text("Login"),
          ),
        ],
      );
    },
  );
}
