import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'table_page.dart';
import 'auth_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // tutaj definiujemy klienta Supabase
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text('ERP Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TablePage(tableName: 'users'),
                    ),
                  ),
              child: const Text('Users'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TablePage(tableName: 'projects'),
                    ),
                  ),
              child: const Text('Projects'),
            ),
            ElevatedButton(
              onPressed: () async {
                // używamy lokalnie zdefiniowanego klienta
                await supabase.auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              },
              child: const Text("🔒 Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
