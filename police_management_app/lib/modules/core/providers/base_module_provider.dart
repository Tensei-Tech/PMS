import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/base_record.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/case_visibility.dart';

class BaseModuleProvider extends ChangeNotifier {
  final String moduleKey;
  final FirestoreService _firestore = FirestoreService();
  StreamSubscription? _sub;
  List<ModuleRecord> _records = [];
  String _stationId = '';
  String _uid = '';
  CaseVisibilityMode _visibilityMode = CaseVisibilityMode.ownCasesOnly;

  BaseModuleProvider(this.moduleKey);

  void setStationContext({
    required String stationId,
    required String uid,
    required CaseVisibilityMode visibilityMode,
  }) {
    if (_stationId == stationId &&
        _uid == uid &&
        _visibilityMode == visibilityMode &&
        _sub != null) {
      return;
    }
    _stationId = stationId;
    _uid = uid;
    _visibilityMode = visibilityMode;
    _sub?.cancel();

    if (stationId.isEmpty) {
      _records = [];
      notifyListeners();
      return;
    }

    _sub = _firestore.getCasesStream(moduleKey, stationId).listen(
      (records) {
        _records = CaseVisibility.filterRecords(
          records,
          uid: _uid,
          mode: _visibilityMode,
        );
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[$moduleKey] Firestore stream error: $e');
      },
    );
  }

  void seedDemoRecords(List<ModuleRecord> demoRecords) {
    if (_records.isEmpty) {
      _records = List.from(demoRecords);
      notifyListeners();
    }
  }

  /// Back-compat shim for form screens that only inject station + uid.
  void setStationId(String stationId, {String createdBy = ''}) {
    setStationContext(
      stationId: stationId,
      uid: createdBy,
      visibilityMode: CaseVisibilityMode.stationWide,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<ModuleRecord> get records => _records;
  int get totalCount => _records.length;
  int get openCount => _records.where((r) => r.status == 'Open').length;
  int get activeCount => _records.where((r) => r.status == 'Active').length;
  int get resolvedCount => _records.where((r) => r.status == 'Resolved').length;
  int get closedCount => _records.where((r) => r.status == 'Closed').length;

  String get stationId => _stationId;
  String get createdBy => _uid;

  ModuleRecord? getById(String id) {
    return _records.firstWhereOrNull((r) => r.id == id);
  }

  List<ModuleRecord> getFilteredRecords(String? subCategory) {
    if (subCategory == null) return records;
    return records.where((r) => r.subCategory == subCategory).toList();
  }

  int getFilteredTotalCount(String? subCategory) {
    if (subCategory == null) return totalCount;
    return records.where((r) => r.subCategory == subCategory).length;
  }

  int getFilteredOpenCount(String? subCategory) {
    if (subCategory == null) return openCount;
    return records.where((r) => r.subCategory == subCategory && r.status == 'Open').length;
  }

  int getFilteredActiveCount(String? subCategory) {
    if (subCategory == null) return activeCount;
    return records.where((r) => r.subCategory == subCategory && r.status == 'Active').length;
  }

  int getFilteredResolvedCount(String? subCategory) {
    if (subCategory == null) return resolvedCount;
    return records.where((r) => r.subCategory == subCategory && r.status == 'Resolved').length;
  }

  int getFilteredClosedCount(String? subCategory) {
    if (subCategory == null) return closedCount;
    return records.where((r) => r.subCategory == subCategory && r.status == 'Closed').length;
  }

  Future<void> addRecord(ModuleRecord record) async {
    if (record.moduleKey != moduleKey) {
      throw ArgumentError(
          'Cannot add a ${record.moduleKey} record into $moduleKey module!');
    }
    final enriched = record.copyWith(
      stationName: record.stationName.isEmpty ? _stationId : record.stationName,
      createdBy: record.createdBy.isEmpty ? _uid : record.createdBy,
      assignedOfficerUid: record.assignedOfficerUid ??
          (_uid.isNotEmpty ? _uid : record.assignedOfficerUid),
    );
    await _firestore.saveCase(enriched, isCreate: true);
  }

  Future<void> updateRecord(ModuleRecord record) async {
    if (record.moduleKey != moduleKey) {
      throw ArgumentError(
          'Cannot update a ${record.moduleKey} record in $moduleKey module!');
    }
    final enriched = record.copyWith(
      stationName: record.stationName.isEmpty ? _stationId : record.stationName,
      createdBy: record.createdBy.isEmpty ? _uid : record.createdBy,
      assignedOfficerUid: record.assignedOfficerUid ??
          (_uid.isNotEmpty ? _uid : record.assignedOfficerUid),
    );
    await _firestore.saveCase(enriched, isCreate: false);
  }

  Future<void> deleteRecord(String id) async {
    await _firestore.deleteCase(id, moduleKey: moduleKey);
  }

  ModuleRecord createRecord({
    required String title,
    required String caseNumber,
    required String description,
    required String complainant,
    required String accused,
    required String location,
    required DateTime incidentDate,
    required String priority,
    required String assignedOfficer,
    String? subCategory,
    Map<String, dynamic>? extraFields,
    String? assignedOfficerUid,
  }) {
    return ModuleRecord(
      id: const Uuid().v4(),
      moduleKey: moduleKey,
      title: title,
      caseNumber: caseNumber,
      description: description,
      complainant: complainant,
      accused: accused,
      location: location,
      incidentDate: incidentDate,
      priority: priority,
      status: 'Open',
      assignedOfficer: assignedOfficer,
      subCategory: subCategory,
      extraFields: extraFields ?? {},
      stationName: _stationId,
      createdBy: _uid,
      assignedOfficerUid: assignedOfficerUid ?? (_uid.isNotEmpty ? _uid : null),
    );
  }
}
