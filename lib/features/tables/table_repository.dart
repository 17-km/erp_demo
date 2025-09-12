import 'package:erp_demo/services/supabase_service.dart';

/// Abstrakcyjny kontrakt repozytorium
abstract class TableRepository {
  Future<List<Map<String, dynamic>>> getRows(String table);
  Future<Map<String, dynamic>> insertRow(
    String table,
    Map<String, dynamic> values,
  );
  Future<Map<String, dynamic>> updateRow(
    String table,
    dynamic id,
    Map<String, dynamic> values,
  );
  Future<void> deleteRow(String table, dynamic id);
}

/// Implementacja oparta o Supabase
class SupabaseTableRepository implements TableRepository {
  final SupabaseService service;

  SupabaseTableRepository(this.service);

  @override
  Future<List<Map<String, dynamic>>> getRows(String table) {
    return service.getRows(table);
  }

  @override
  Future<Map<String, dynamic>> insertRow(
    String table,
    Map<String, dynamic> values,
  ) {
    return service.insertRow(table, values);
  }

  @override
  Future<Map<String, dynamic>> updateRow(
    String table,
    dynamic id,
    Map<String, dynamic> values,
  ) {
    return service.updateRow(table, id, values);
  }

  @override
  Future<void> deleteRow(String table, dynamic id) {
    return service.deleteRow(table, id);
  }
}
