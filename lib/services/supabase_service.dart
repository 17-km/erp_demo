import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRows(String table) async {
    final response = await supabase.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertRow(
    String table,
    Map<String, dynamic> values,
  ) async {
    final response =
        await supabase
            .from(table)
            .insert(values)
            .select()
            .single(); // zwróci 1 rekord
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updateRow(
    String table,
    dynamic id,
    Map<String, dynamic> values,
  ) async {
    final response =
        await supabase
            .from(table)
            .update(values)
            .eq('id', id)
            .select()
            .single();
    return Map<String, dynamic>.from(response);
  }

  Future<void> deleteRow(String table, dynamic id) async {
    await supabase.from(table).delete().eq('id', id);
  }

  Future<List<String>> getTableColumns(String tableName) async {
    final response = await supabase
        .from('information_schema.columns')
        .select('column_name')
        .eq('table_name', tableName)
        .order('ordinal_position', ascending: true);

    // zwracamy tylko nazwy kolumn
    return (response as List)
        .map((row) => row['column_name'] as String)
        .where((c) => c != 'id' && c != 'created_at') // pomiń techniczne
        .toList();
  }
}
