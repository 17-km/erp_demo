import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tables/table_page.dart';
import 'package:erp_demo/features/admin/admin_panel.dart';
import '../auth/auth_provider.dart'; // używamy tylko providera (AuthPage już niepotrzebny tu)

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ERP Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TablePage(tableName: 'users'),
                  ),
                );
              },
              child: const Text('Users'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const TablePage(tableName: 'projects'),
                  ),
                );
              },
              child: const Text('Projects'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanel()),
                );
              },
              child: const Text('Projects'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                // RootRouter sam przełączy na AuthPage po utracie sesji
              },
              child: const Text('🔒 Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
