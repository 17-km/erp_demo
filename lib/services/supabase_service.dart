import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<String>> getTables() async {
    final res = await supabase.rpc('admin_list_tables');
    final list = List<Map<String, dynamic>>.from(res as List);
    return list.map((e) => e['table_name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getRows(String table) async {
    final response = await supabase.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertRow(
    String table,
    Map<String, dynamic> values,
  ) async {
    final response =
        await supabase.from(table).insert(values).select().single();
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

  /// Surowe metadane kolumn (RPC)
  Future<List<ColumnMeta>> getTableColumnsMeta(String tableName) async {
    final res = await supabase.rpc(
      'admin_list_columns',
      params: {'p_table': tableName},
    );
    final list = List<Map<String, dynamic>>.from(res as List);
    return list.map(ColumnMeta.fromJson).toList();
  }

  /// Kolumny edytowalne w genericznym dialogu:
  /// - wyrzucamy techniczne: id, created_at, updated_at
  /// - wyrzucamy te z defaultem gen_random_uuid() / now()
  Future<List<String>> getEditableColumns(String tableName) async {
    final meta = await getTableColumnsMeta(tableName);
    final blocked = {'id', 'created_at', 'updated_at'};

    bool isTechnicalDefault(String? d) {
      if (d == null) return false;
      final dd = d.toLowerCase();
      return dd.contains('gen_random_uuid()') || dd.startsWith('now()');
    }

    return meta
        .where((c) => !blocked.contains(c.columnName))
        .where((c) => !isTechnicalDefault(c.columnDefault))
        .map((c) => c.columnName)
        .toList();
  }
}

class ColumnMeta {
  final String columnName;
  final String dataType;
  final bool isNullable;
  final String? columnDefault;

  ColumnMeta({
    required this.columnName,
    required this.dataType,
    required this.isNullable,
    required this.columnDefault,
  });

  factory ColumnMeta.fromJson(Map<String, dynamic> json) => ColumnMeta(
    columnName: json['column_name'] as String,
    dataType: json['data_type'] as String,
    isNullable: json['is_nullable'] as bool? ?? false,
    columnDefault: json['column_default'] as String?,
  );
}

/// Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
