import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Pokazuje główne okno logowania.
Future<void> showLoginDialog(BuildContext context) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool busy = false;

  await showDialog(
    context: context,
    barrierDismissible: !busy,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> _doLogin() async {
            if (busy) return;
            final email = emailController.text.trim();
            final pass = passwordController.text.trim();
            if (email.isEmpty || pass.isEmpty) {
              _alert(ctx, 'Login failed', 'Please enter email and password.');
              return;
            }
            setState(() => busy = true);
            try {
              final res = await supabase.auth.signInWithPassword(
                email: email,
                password: pass,
              );
              if (!ctx.mounted) return;
              if (res.user != null) {
                Navigator.pop(ctx); // zamknij dialog
                // Navigator.pushReplacementNamed(ctx, '/home');
              } else {
                _alert(ctx, 'Login failed', 'Login failed. Please try again.');
              }
            } on AuthException catch (e) {
              if (!ctx.mounted) return;
              _alert(ctx, 'Login failed', e.message);
            } catch (e) {
              if (!ctx.mounted) return;
              _alert(ctx, 'Unexpected error', e.toString());
            } finally {
              if (ctx.mounted) setState(() => busy = false);
            }
          }

          Future<void> _forgotPassword() async {
            // Pokaż mini-dialog proszący o e-mail (z pre-fill)
            final entered = await _askEmailDialog(
              ctx,
              initialEmail: emailController.text.trim(),
            );
            if (entered == null) return; // user anulował
            final email = entered.trim();
            if (email.isEmpty) {
              _alert(ctx, 'Reset failed', 'Please enter your email.');
              return;
            }

            setState(() => busy = true);
            try {
              await supabase.auth.resetPasswordForEmail(
                email,
                // MUSI być na whiteliście w Supabase → Auth → Redirect URLs
                redirectTo: 'erpdemo://auth-callback?flow=reset',
              );
              if (!ctx.mounted) return;
              _alert(
                ctx,
                'Check your email',
                'If an account with this email exists, we have sent you a link to reset your password.\nLinks are one-time and expire quickly.',
              );
            } on AuthException catch (e) {
              if (!ctx.mounted) return;
              _alert(ctx, 'Reset failed', e.message);
            } catch (e) {
              if (!ctx.mounted) return;
              _alert(ctx, 'Unexpected error', e.toString());
            } finally {
              if (ctx.mounted) setState(() => busy = false);
            }
          }

          final canSubmit =
              emailController.text.trim().isNotEmpty &&
              passwordController.text.trim().isNotEmpty &&
              !busy;

          return AlertDialog(
            title: const Text("Login"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _doLogin(),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _doLogin(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: busy ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: canSubmit ? _doLogin : null,
                child:
                    busy
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text("Login"),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Prosty mini-dialog proszący o e-mail. Zwraca wpisany e-mail albo null (anulowano).
Future<String?> _askEmailDialog(
  BuildContext context, {
  String initialEmail = '',
}) async {
  final ctrl = TextEditingController(text: initialEmail);
  String? result;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Your email',
            hintText: 'name@example.com',
          ),
          onSubmitted: (_) {
            result = ctrl.text;
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              result = ctrl.text;
              Navigator.pop(ctx);
            },
            child: const Text('Send link'),
          ),
        ],
      );
    },
  );

  return result;
}

/// Krótki helper do pokazywania komunikatów.
void _alert(BuildContext ctx, String title, String message) {
  showDialog(
    context: ctx,
    builder:
        (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}
