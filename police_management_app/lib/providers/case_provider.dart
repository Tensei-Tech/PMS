// lib/providers/case_provider.dart
import 'package:flutter/material.dart';

class CaseRecord {
  final String id;
  final String title;
  final String category;
  final String description;
  final String caseNumber;
  final String complainant;
  final String accused;
  final String location;
  final DateTime incidentDate;
  final String priority;
  final String status;
  final String assignedOfficer;

  CaseRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.caseNumber,
    required this.complainant,
    required this.accused,
    required this.location,
    required this.incidentDate,
    required this.priority,
    required this.status,
    required this.assignedOfficer,
  });

  CaseRecord copyWith({
    String? title,
    String? category,
    String? description,
    String? caseNumber,
    String? complainant,
    String? accused,
    String? location,
    DateTime? incidentDate,
    String? priority,
    String? status,
    String? assignedOfficer,
  }) {
    return CaseRecord(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      caseNumber: caseNumber ?? this.caseNumber,
      complainant: complainant ?? this.complainant,
      accused: accused ?? this.accused,
      location: location ?? this.location,
      incidentDate: incidentDate ?? this.incidentDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
    );
  }
}

class CaseProvider extends ChangeNotifier {
  final List<CaseRecord> _cases = [
    CaseRecord(
      id: '1',
      title: 'Theft at Market Road',
      caseNumber: 'FIR/2024/0451',
      category: 'Theft',
      description: 'Laptops and electronics stolen from a shop at midnight.',
      complainant: 'John Doe',
      accused: 'Unknown',
      location: 'Market Road, Sector 4',
      incidentDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: 'High',
      status: 'Open',
      assignedOfficer: 'SI Ramesh',
    ),
    CaseRecord(
      id: '2',
      title: 'Missing Person Report',
      caseNumber: 'FIR/2024/0448',
      category: 'Missing',
      description: 'A 12-year old boy missing since yesterday evening.',
      complainant: 'Sara Smith',
      accused: 'N/A',
      location: 'Green Park colony',
      incidentDate: DateTime.now().subtract(const Duration(days: 2)),
      priority: 'High',
      status: 'Active',
      assignedOfficer: 'SI Priya',
    ),
    CaseRecord(
      id: '3',
      title: 'Road Dispute & Hurt',
      caseNumber: 'FIR/2024/0445',
      category: 'Hurt',
      description: 'Fight occurred between two drivers regarding parking.',
      complainant: 'Michael Ross',
      accused: 'Harvey Specter',
      location: 'Lawyer Street',
      incidentDate: DateTime.now().subtract(const Duration(days: 3)),
      priority: 'Medium',
      status: 'Resolved',
      assignedOfficer: 'SI Kumar',
    ),
  ];

  List<CaseRecord> get allCases => List.unmodifiable(_cases);

  List<CaseRecord> getCasesByCategory(String category) {
    if (category == 'Form I-V' || category == 'Form VI') {
      // In this demo, Form types are grouped or specific
      return _cases.where((c) => c.category == category || c.category == 'Theft').toList();
    }
    return _cases.where((c) => c.category == category).toList();
  }

  void addCase(CaseRecord newCase) {
    _cases.insert(0, newCase);
    notifyListeners();
  }

  void updateCase(CaseRecord updatedCase) {
    final index = _cases.indexWhere((c) => c.id == updatedCase.id);
    if (index != -1) {
      _cases[index] = updatedCase;
      notifyListeners();
    }
  }

  void deleteCase(String id) {
    _cases.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
