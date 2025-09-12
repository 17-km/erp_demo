import 'package:flutter/material.dart';

class AddRowDialog extends StatefulWidget {
  final String tableName;
  final List<String> columns;

  const AddRowDialog({
    super.key,
    required this.tableName,
    required this.columns,
  });

  @override
  State<AddRowDialog> createState() => _AddRowDialogState();
}

class _AddRowDialogState extends State<AddRowDialog> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (var col in widget.columns) {
      controllers[col] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Dodaj rekord do ${widget.tableName}"),
      content: SingleChildScrollView(
        child: Column(
          children:
              widget.columns.map((col) {
                return TextField(
                  controller: controllers[col],
                  decoration: InputDecoration(labelText: col),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Anuluj"),
        ),
        ElevatedButton(
          onPressed: () {
            final row = <String, dynamic>{};
            for (var col in widget.columns) {
              row[col] =
                  controllers[col]!.text.isEmpty
                      ? null
                      : controllers[col]!.text;
            }
            Navigator.of(context).pop(row);
          },
          child: const Text("Zapisz"),
        ),
      ],
    );
  }
}
