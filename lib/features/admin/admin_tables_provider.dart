import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lista tabel z widoku app_tables
final adminTablesProvider = FutureProvider<List<String>>((ref) async {
  final supabase = Supabase.instance.client;
  final resp = await supabase.from('app_tables').select('table_name');
  return (resp as List).map((r) => r['table_name'] as String).toList();
});

/// Lista EDYTOWALNYCH kolumn dla danej tabeli.
/// 1) próbuje widoku app_columns (rekomendowane),
/// 2) jeśli pusto lub błąd – fallback: information_schema.columns,
/// 3) filtruje kolumny techniczne.
final tableColumnsProvider = FutureProvider.family<List<String>, String>((
  ref,
  tableName,
) async {
  final supabase = Supabase.instance.client;

  // 1) widok app_columns (jeśli masz go w DB)
  try {
    final resp = await supabase
        .from('app_columns')
        .select('column_name,is_editable')
        .eq('table_name', tableName)
        .eq('is_editable', true);

    final list = (resp as List).map((r) => r['column_name'] as String).toList();
    if (list.isNotEmpty) return list;
  } catch (_) {
    // ignorujemy i schodzimy do fallbacku
  }

  // 2) fallback: information_schema.columns (może nie być wystawione przez PostgREST)
  try {
    final resp = await supabase
        .from('information_schema.columns')
        .select('column_name, ordinal_position, table_schema, table_name')
        .eq('table_schema', 'public')
        .eq('table_name', tableName)
        .order('ordinal_position');

    final list =
        (resp as List)
            .map((r) => r['column_name'] as String)
            .where((c) => c != 'id' && c != 'created_at' && c != 'updated_at')
            .toList();

    if (list.isNotEmpty) return list;
  } catch (_) {
    // ignorujemy
  }

  // 3) ostatecznie pusto
  return <String>[];
});
