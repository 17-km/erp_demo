import 'package:flutter/material.dart';
import 'admin_tables_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_demo/features/tables/table_page.dart';

class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(adminTablesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: tablesAsync.when(
        data: (tables) {
          if (tables.isEmpty) {
            return const Center(child: Text('No tables in the database'));
          }
          return ListView.builder(
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return ListTile(
                title: Text(table),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TablePage(tableName: table),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('❌ Error: $err')),
      ),
    );
  }
}
