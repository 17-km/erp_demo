import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_demo/features/tables/table_provider.dart';
import 'package:erp_demo/features/admin/admin_tables_provider.dart';
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
            return const Center(child: Text('No data'));
          }

          final allColumns = rows.first.keys.toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                ...allColumns.map((c) => DataColumn(label: Text(c))),
                const DataColumn(label: Text('Actions')),
              ],
              rows:
                  rows.map((row) {
                    return DataRow(
                      cells: [
                        ...allColumns.map((c) {
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
                            onPressed: () async {
                              final ok = await _confirmDelete(context);
                              if (ok == true) {
                                await ref
                                    .read(tableProvider(tableName).notifier)
                                    .deleteRow(row['id']);
                              }
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Kolumny bierzemy ze schematu (działa także przy pustej tabeli)
          final List<String> columns = await ref.read(
            tableColumnsProvider(tableName).future,
          );

          if (columns.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No editable columns found for this table.'),
                ),
              );
            }
            return;
          }

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

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete row'),
            content: const Text('Are you sure you want to delete this row?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
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

    dynamic _parse(String raw) {
      final v = raw.trim();
      if (v.isEmpty) return null;

      final asInt = int.tryParse(v);
      if (asInt != null) return asInt;

      final asDouble = double.tryParse(v);
      if (asDouble != null) return asDouble;

      if (v.toLowerCase() == 'true') return true;
      if (v.toLowerCase() == 'false') return false;

      try {
        return DateTime.parse(v).toIso8601String();
      } catch (_) {
        return v; // string
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit $column'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'New value for $column'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = _parse(controller.text);
                await ref.read(tableProvider(tableName).notifier).updateRow(
                  row['id'],
                  {column: value},
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
