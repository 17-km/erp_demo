import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRows(String table) async {
    final data = await client.from(table).select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> insertRow(String table, Map<String, dynamic> values) async {
    await client.from(table).insert(values);
  }

  Future<void> updateRow(
    String table,
    Map<String, dynamic> values,
    String id,
  ) async {
    await client.from(table).update(values).eq('id', id);
  }
}
