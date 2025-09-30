// lib/features/tables/widgets/add_row_dialog.dart
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
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final col in widget.columns) {
      _controllers[col] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  dynamic _parseValue(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;

    final asInt = int.tryParse(v);
    if (asInt != null) return asInt;

    final asDouble = double.tryParse(v);
    if (asDouble != null) return asDouble;

    if (v.toLowerCase() == 'true') return true;
    if (v.toLowerCase() == 'false') return false;

    try {
      final dt = DateTime.parse(v);
      return dt.toIso8601String();
    } catch (_) {
      return v; // string
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add record to "${widget.tableName}"'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                widget.columns.map((col) {
                  final ctrl = _controllers[col]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: ctrl,
                      decoration: InputDecoration(labelText: col),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final payload = <String, dynamic>{};
            for (final col in widget.columns) {
              payload[col] = _parseValue(_controllers[col]!.text);
            }
            Navigator.of(context).pop(payload);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
