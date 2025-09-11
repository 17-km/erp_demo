import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TablePage extends StatefulWidget {
  final String tableName;
  const TablePage({super.key, required this.tableName});

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final supabase = Supabase.instance.client;
  List<DataColumn> columns = [];
  List<DataRow> rows = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data =
          await supabase.from(widget.tableName).select() as List<dynamic>;

      if (data.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final keys = (data.first as Map<String, dynamic>).keys.toList();
      final fetchedColumns =
          keys.map((key) => DataColumn(label: Text(key))).toList();

      final fetchedRows =
          data.map((row) {
            final cells =
                keys
                    .map((key) => DataCell(Text(row[key]?.toString() ?? '')))
                    .toList();
            return DataRow(cells: cells);
          }).toList();

      setState(() {
        columns = fetchedColumns;
        rows = fetchedRows;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : error != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ],
                )
                : columns.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No data available'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(columns: columns, rows: rows),
                ),
      ),
    );
  }
}
