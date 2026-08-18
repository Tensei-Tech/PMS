// lib/modules/core/repositories/base_repository.dart
// Abstract contract all module repositories must implement.
// Swap InMemoryRepository → FirestoreRepository without touching UI code.

import '../models/base_record.dart';

abstract class BaseRepository {
  /// Returns all records for this module (never shared with other modules).
  List<ModuleRecord> getAll();

  /// Returns a single record by ID, or null if not found.
  ModuleRecord? getById(String id);

  /// Adds a new record. Should prepend to keep newest-first order.
  void add(ModuleRecord record);

  /// Replaces an existing record matched by ID.
  void update(ModuleRecord record);

  /// Removes a record by ID.
  void delete(String id);

  /// Total count of records for stats display.
  int get totalCount;

  /// Count by status for stats cards.
  int countByStatus(String status);
}
