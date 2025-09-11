import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ResetPasswordPage extends StatefulWidget {
  final String? accessToken;
  const ResetPasswordPage({super.key, this.accessToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  bool _busy = false;

  Future<void> _updatePassword() async {
    if (_pwdCtrl.text.trim().isEmpty || _pwdCtrl.text != _pwd2Ctrl.text) {
      _showMsg("Passwords don't match.");
      return;
    }

    setState(() => _busy = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _pwdCtrl.text.trim()),
      );

      if (!mounted) return;

      // ✅ Wyloguj po zmianie hasła
      await supabase.auth.signOut();

      // ✅ Pokaż komunikat i wróć na /auth
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Password updated'),
              content: const Text(
                'Your password has been updated.\nPlease log in with the new password.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // zamyka dialog
                    // Navigator.pushNamedAndRemoveUntil(
                    //   context,
                    //   '/auth',
                    //   (r) => false,
                    // );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showMsg(e.message);
    } catch (e) {
      if (!mounted) return;
      _showMsg('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.accessToken == null)
              const Text(
                'No token found in the link. Please use the reset link from your email.',
              ),
            TextField(
              controller: _pwdCtrl,
              decoration: const InputDecoration(labelText: 'New password'),
              obscureText: true,
            ),
            TextField(
              controller: _pwd2Ctrl,
              decoration: const InputDecoration(labelText: 'Repeat password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _updatePassword,
              child:
                  _busy
                      ? const CircularProgressIndicator()
                      : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
