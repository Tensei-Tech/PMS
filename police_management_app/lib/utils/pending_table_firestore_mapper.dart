// Converts [ModuleRecord] from `pending_cases` into table rows for
// [PendingCasesDemoDataTable] / Pending Summary / Pending demo table screens.

import 'package:intl/intl.dart';

import '../modules/core/models/base_record.dart';
import 'common_form_module.dart';
import 'pending_io_wise_logic.dart';

final _regDateFmt = DateFormat('dd/MM/yyyy');

/// UI time-period labels aligned with Pending Cases time-range filters.
/// Uses [anchor] vs [reference] (usually `DateTime.now()`).
String pendingTablePeriodLabel(DateTime anchor, DateTime reference) {
  if (anchor.isAfter(reference)) return 'Within 3 months';
  final days = reference.difference(anchor).inDays;
  if (days >= 366) return 'More than 1 year';
  if (days >= 184) return '6 to 12 months';
  if (days >= 92) return '3 to 6 months';
  if (days >= 32) return 'More than 3 months';
  if (days <= 30) return '1 month';
  return 'Within 3 months';
}

String _sectionsLine(ModuleRecord r) {
  final raw = r.extraFields[kCommonFormExtraFieldsKey];
  if (raw is Map<String, dynamic>) {
    final ch = raw['charges'];
    if (ch is Map) {
      final parts = <String>[];
      for (final entry in ch.entries) {
        final v = entry.value;
        if (v is Map) {
          final act = v['act']?.toString().trim();
          final secs = v['sections'];
          if (secs is List && secs.isNotEmpty) {
            parts.add('$act ${secs.join(', ')}'.trim());
          } else if (act != null && act.isNotEmpty) {
            parts.add(act);
          }
        }
      }
      if (parts.isNotEmpty) return parts.join('; ');
    }
  }
  return r.firestoreCategoryDisplayName.trim();
}

String _reasonLine(ModuleRecord r) {
  final d = r.description.trim();
  if (d.isNotEmpty) return d;
  return r.title.trim();
}

String _headLine(ModuleRecord r) {
  final sub = r.subCategory?.trim();
  if (sub != null && sub.isNotEmpty) return sub;
  return r.firestoreCategoryDisplayName.trim();
}

String _spotLine(ModuleRecord r) {
  final spot = [
    () {
      final raw = r.extraFields[kCommonFormExtraFieldsKey];
      if (raw is Map<String, dynamic>) {
        final parts = <String>[
          raw['spotVillage']?.toString().trim() ?? '',
          raw['spotArea']?.toString().trim() ?? '',
          raw['spotAddress']?.toString().trim() ?? '',
        ].where((s) => s.isNotEmpty).toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
      return '';
    }(),
    r.location.trim(),
  ].firstWhere((s) => s.isNotEmpty, orElse: () => '');
  return spot;
}

/// One row map: keys `sr`, `cr`, `sections`, `date`, `io`, `reason`, `period`, `head`
/// plus optional `spot` for AD column.
Map<String, String> pendingModuleRecordToTableRow(
  ModuleRecord r,
  DateTime reference, {
  required int sr,
}) {
  final io =
      pendingIoWiseIoDisplayName(r) ?? r.assignedOfficer.trim();
  return {
    'sr': '$sr',
    'cr': r.caseNumber.trim(),
    'sections': _sectionsLine(r),
    'date': _regDateFmt.format(r.incidentDate),
    'io': io.isEmpty ? '—' : io,
    'reason': _reasonLine(r),
    'period': pendingTablePeriodLabel(r.incidentDate, reference),
    'head': _headLine(r),
    'spot': _spotLine(r),
  };
}

List<Map<String, String>> pendingModuleRecordsToTableRows(
  List<ModuleRecord> records,
  DateTime reference,
) {
  final sorted = List<ModuleRecord>.from(records)
      .where((r) => r.moduleKey != 'nc')
      .toList()
    ..sort((a, b) => b.incidentDate.compareTo(a.incidentDate));
  return List<Map<String, String>>.generate(
    sorted.length,
    (i) => pendingModuleRecordToTableRow(
      sorted[i],
      reference,
      sr: i + 1,
    ),
  );
}

/// Pending collection cases for station [stationId], limited to dashboard category chip.
List<Map<String, String>> pendingTableRowsForCategory(
  List<ModuleRecord> pendingRecords,
  String dashboardCategory,
  DateTime reference,
) {
  final filtered = pendingRecords.where(
    (r) => pendingRecordMatchesDashboardCategory(
      r: r,
      dashboardCategory: dashboardCategory,
    ),
  );
  return pendingModuleRecordsToTableRows(filtered.toList(), reference);
}

/// All pending rows mapped (no category filter — summary).
List<Map<String, String>> pendingTableRowsAll(
  List<ModuleRecord> pendingRecords,
  DateTime reference,
) {
  return pendingModuleRecordsToTableRows(pendingRecords, reference);
}
