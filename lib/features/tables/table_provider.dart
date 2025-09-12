import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_demo/services/supabase_service.dart';
import 'package:erp_demo/features/tables/table_repository.dart';

/// Provider repozytorium (jedno źródło prawdy)
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final service = SupabaseService();
  return SupabaseTableRepository(service);
});

/// Notifier trzyma stan AsyncValue i obsługuje CRUD
class TableNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TableRepository repository;
  final String table;

  TableNotifier(this.repository, this.table)
    : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final rows = await repository.getRows(table);
      state = AsyncValue.data(rows);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRow(Map<String, dynamic> values) async {
    try {
      final newRow = await repository.insertRow(table, values);
      state.whenData((rows) => state = AsyncValue.data([...rows, newRow]));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRow(dynamic id, Map<String, dynamic> values) async {
    try {
      final updated = await repository.updateRow(table, id, values);
      state.whenData((rows) {
        final updatedList =
            rows.map((r) => r['id'] == id ? updated : r).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRow(dynamic id) async {
    try {
      await repository.deleteRow(table, id);
      state.whenData((rows) {
        final updatedList = rows.where((r) => r['id'] != id).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider family – osobny stan dla każdej tabeli
final tableProvider = StateNotifierProvider.family<
  TableNotifier,
  AsyncValue<List<Map<String, dynamic>>>,
  String
>((ref, table) {
  final repo = ref.watch(tableRepositoryProvider);
  return TableNotifier(repo, table);
});
