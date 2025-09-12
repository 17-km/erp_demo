import 'package:flutter/material.dart';
import 'package:erp_demo/features/tables/table_page.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tables = [
      'users',
      'projects',
      'tasks',
    ]; // TODO: pobierać dynamicznie z DB

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: ListView.builder(
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          return ListTile(
            title: Text(table),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TablePage(tableName: table)),
              );
            },
          );
        },
      ),
    );
  }
}
