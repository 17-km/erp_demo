import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ERP Demo"),
        actions: [
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final userId = supabase.auth.currentUser?.id;
                if (userId != null) {
                  await supabase.from('users').insert({
                    'id': userId,
                    'name': 'Jan Kowalski',
                  });
                  print("User inserted!");
                }
              },
              child: const Text("➕ Add user"),
            ),
            ElevatedButton(
              onPressed: () async {
                final users = await supabase.from('users').select();
                print("Users: $users");
              },
              child: const Text("📥 Fetch users"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userId = supabase.auth.currentUser?.id;
                if (userId != null) {
                  await supabase.from('projects').insert({
                    'user_id': userId,
                    'title': 'Projekt A',
                  });
                  print("Project inserted!");
                }
              },
              child: const Text("➕ Add project"),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = supabase.auth.currentUser?.id;
                if (userId != null) {
                  final projects = await supabase
                      .from('projects')
                      .select()
                      .eq('user_id', userId);
                  print("Projects: $projects");
                }
              },
              child: const Text("📥 Fetch projects"),
            ),
            ElevatedButton(
              onPressed: () async {
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
