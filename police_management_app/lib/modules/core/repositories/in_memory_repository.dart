// lib/modules/core/repositories/in_memory_repository.dart
// Default implementation: per-instance isolated in-memory list.
// Every module gets its OWN instance → zero cross-module data leakage.
// Future: swap to FirestoreRepository without changing any provider or UI code.

import 'base_repository.dart';
import '../models/base_record.dart';

class InMemoryRepository implements BaseRepository {
  // Private, non-static list → isolated to this class instance
  final List<ModuleRecord> _store = [];

  @override
  List<ModuleRecord> getAll() => List.unmodifiable(_store);

  @override
  ModuleRecord? getById(String id) {
    try {
      return _store.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void add(ModuleRecord record) {
    _store.insert(0, record); // newest first
  }

  @override
  void update(ModuleRecord record) {
    final idx = _store.indexWhere((r) => r.id == record.id);
    if (idx != -1) _store[idx] = record;
  }

  @override
  void delete(String id) {
    _store.removeWhere((r) => r.id == id);
  }

  @override
  int get totalCount => _store.length;

  @override
  int countByStatus(String status) =>
      _store.where((r) => r.status == status).length;
}
