// lib/modules/core/models/base_record.dart
// Shared data model for all police case modules.
// Each module's record extends or uses this to prevent data-mixing.

class ModuleRecord {
  final String id;
  final String moduleKey;  // unique per module e.g. 'nc', 'theft', 'pocso'
  final String title;
  final String caseNumber;
  final String description;
  final String complainant;
  final String accused;
  final String location;
  final DateTime incidentDate;
  final String priority;
  final String status;
  final String assignedOfficer;
  final DateTime createdAt;
  final String? subCategory; // for Forms like I-V that have sub-types e.g. 'Murder'
  // Module-specific fields stored without polluting the common schema
  final Map<String, dynamic> extraFields;
  // Station-level isolation & audit fields
  final String createdBy;   // Firebase Auth UID of the creating officer
  final String? assignedOfficerUid; // Firebase UID of assigned I.O., when known
  final String stationName; // Station name — all officers in the same station share data

  ModuleRecord({
    required this.id,
    required this.moduleKey,
    required this.title,
    required this.caseNumber,
    required this.description,
    required this.complainant,
    required this.accused,
    required this.location,
    required this.incidentDate,
    required this.priority,
    required this.status,
    required this.assignedOfficer,
    this.subCategory,
    DateTime? createdAt,
    Map<String, dynamic>? extraFields,
    this.createdBy = '',
    this.assignedOfficerUid,
    this.stationName = '',
  })  : createdAt = createdAt ?? DateTime.now(),
        extraFields = extraFields ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleKey': moduleKey,
      'title': title,
      'caseNumber': caseNumber,
      'description': description,
      'complainant': complainant,
      'accused': accused,
      'location': location,
      'incidentDate': incidentDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assignedOfficer': assignedOfficer,
      'subCategory': subCategory,
      'createdAt': createdAt.toIso8601String(),
      'extraFields': extraFields,
      'createdBy': createdBy,
      if (assignedOfficerUid != null && assignedOfficerUid!.trim().isNotEmpty)
        'assignedOfficerUid': assignedOfficerUid,
      'stationName': stationName,
    };
  }

  factory ModuleRecord.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ModuleRecord(
      id: docId ?? map['id'] ?? '',
      moduleKey: map['moduleKey'] ?? '',
      title: map['title'] ?? '',
      caseNumber: map['caseNumber'] ?? '',
      description: map['description'] ?? '',
      complainant: map['complainant'] ?? '',
      accused: map['accused'] ?? '',
      location: map['location'] ?? '',
      incidentDate: DateTime.parse(map['incidentDate'] ?? DateTime.now().toIso8601String()),
      priority: map['priority'] ?? 'Low',
      status: map['status'] ?? 'Open',
      assignedOfficer: map['assignedOfficer'] ?? '',
      subCategory: map['subCategory'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      extraFields: map['extraFields'] != null 
          ? Map<String, dynamic>.from(map['extraFields']) 
          : {},
      createdBy: map['createdBy'] ?? '',
      assignedOfficerUid: map['assignedOfficerUid'] as String?,
      stationName: map['stationName'] ?? map['stationId'] ?? '',
    );
  }

  ModuleRecord copyWith({
    String? title,
    String? caseNumber,
    String? description,
    String? complainant,
    String? accused,
    String? location,
    DateTime? incidentDate,
    String? priority,
    String? status,
    String? assignedOfficer,
    String? subCategory,
    Map<String, dynamic>? extraFields,
    String? createdBy,
    String? assignedOfficerUid,
    String? stationName,
  }) {
    return ModuleRecord(
      id: id,
      moduleKey: moduleKey,
      title: title ?? this.title,
      caseNumber: caseNumber ?? this.caseNumber,
      description: description ?? this.description,
      complainant: complainant ?? this.complainant,
      accused: accused ?? this.accused,
      location: location ?? this.location,
      incidentDate: incidentDate ?? this.incidentDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
      subCategory: subCategory ?? this.subCategory,
      createdAt: createdAt,
      extraFields: extraFields ?? this.extraFields,
      createdBy: createdBy ?? this.createdBy,
      assignedOfficerUid: assignedOfficerUid ?? this.assignedOfficerUid,
      stationName: stationName ?? this.stationName,
    );
  }

  /// Convert to a CaseRecord-like display by returning itself (used for PDF, details screen).
  String get category => moduleKey;

  /// Human-readable module/category line from fields on the Firestore case document
  /// ([extraFields.moduleDisplayName], [subCategory], then humanized [moduleKey]).
  String get firestoreCategoryDisplayName {
    final raw = extraFields['moduleDisplayName'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    final sc = subCategory?.trim();
    if (sc != null && sc.isNotEmpty) return sc;
    final mk = moduleKey.trim();
    if (mk.isEmpty) return '';
    return mk.replaceAll('_', ' ');
  }

  @override
  String toString() => 'ModuleRecord[$moduleKey]($id: $title)';
}
