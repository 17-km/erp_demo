import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_demo/features/tables/table_provider.dart';
import 'widgets/add_row_dialog.dart';

class TablePage extends ConsumerWidget {
  final String tableName;

  const TablePage({super.key, required this.tableName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRows = ref.watch(tableProvider(tableName));

    return Scaffold(
      appBar: AppBar(title: Text('Table: $tableName')),
      body: asyncRows.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text("Brak danych"));
          }

          final columns = rows.first.keys.toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                ...columns.map((c) => DataColumn(label: Text(c))),
                const DataColumn(label: Text("Akcje")),
              ],
              rows:
                  rows.map((row) {
                    return DataRow(
                      cells: [
                        ...columns.map((c) {
                          return DataCell(
                            Text('${row[c]}'),
                            onTap: () {
                              _showEditDialog(context, ref, tableName, row, c);
                            },
                          );
                        }),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(tableProvider(tableName).notifier)
                                  .deleteRow(row['id']);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Błąd: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final columns =
              asyncRows.asData?.value.isNotEmpty == true
                  ? asyncRows.asData!.value.first.keys.toList()
                  : <String>[];

          final newRow = await showDialog<Map<String, dynamic>>(
            context: context,
            builder:
                (_) => AddRowDialog(tableName: tableName, columns: columns),
          );

          if (newRow != null) {
            await ref.read(tableProvider(tableName).notifier).addRow(newRow);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String tableName,
    Map<String, dynamic> row,
    String column,
  ) {
    final controller = TextEditingController(text: '${row[column]}');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Edytuj $column"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Nowa wartość dla $column"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(tableProvider(tableName).notifier).updateRow(
                  row['id'],
                  {column: controller.text},
                );
                Navigator.pop(context);
              },
              child: const Text("Zapisz"),
            ),
          ],
        );
      },
    );
  }
}
