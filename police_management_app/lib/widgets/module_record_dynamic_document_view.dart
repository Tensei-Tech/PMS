// lib/widgets/module_record_dynamic_document_view.dart
// Dynamic read-only view for dashboard module cases: every key in the saved hub record
// (including nested extraFields) with automatic labels — stays in sync when fields are added.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../modules/core/models/base_record.dart';
import '../theme/app_theme.dart';
import '../utils/common_form_module.dart';
import 'ad_form_dynamic_document_view.dart' show humanizeFieldKey;
import 'common_form_document_view.dart';

const Map<String, String> kModuleHubFieldLabels = {
  'id': 'Record ID',
  'moduleKey': 'Module code',
  'title': 'Case title',
  'caseNumber': 'Case / FIR no.',
  'description': 'Description',
  'complainant': 'Complainant',
  'accused': 'Accused',
  'location': 'Location',
  'incidentDate': 'Incident date',
  'priority': 'Priority',
  'status': 'Status',
  'assignedOfficer': 'Assigned officer',
  'subCategory': 'Sub-category / crime type',
  'createdAt': 'Registered on',
  'createdBy': 'Created by (user id)',
  'stationName': 'Station',
};

/// Preferred display order: matches [ModuleFormScreen] (General → Incident → Parties →
/// Priority & Status), then record metadata as in [ModuleRecord.toMap].
/// Any additional keys on the record keep their map insertion order after these.
const List<String> kModuleHubFieldOrder = [
  'caseNumber',
  'title',
  'incidentDate',
  'location',
  'description',
  'complainant',
  'accused',
  'priority',
  'status',
  'subCategory',
  'assignedOfficer',
  'stationName',
  'createdAt',
  'moduleKey',
  'createdBy',
  'id',
];

/// Hub scalar keys: form order first, then any other keys in [raw] iteration order.
List<String> orderedModuleHubScalarKeys(Map<String, dynamic> raw) {
  final keySet = raw.keys.map((k) => k.toString()).toSet();
  final preferred = <String>[
    for (final k in kModuleHubFieldOrder)
      if (keySet.contains(k)) k,
  ];
  final used = preferred.toSet();
  final rest = <String>[
    for (final k in raw.keys.map((x) => x.toString()))
      if (!used.contains(k)) k,
  ];
  return [...preferred, ...rest];
}

String _labelForRecordKey(String key) =>
    kModuleHubFieldLabels[key] ?? humanizeFieldKey(key);

/// Desktop / PC case-detail layout (matches common_form_document_view breakpoint).
const double _kCaseDetailDesktopBreakpoint = 800;
const double _kCaseDetailMaxContentWidth = 900;
const double _kCaseDetailDesktopHorizontalPadding = 24;

class ModuleRecordDynamicDocumentView extends StatelessWidget {
  final ModuleRecord record;
  final String moduleLabel;

  const ModuleRecordDynamicDocumentView({
    super.key,
    required this.record,
    required this.moduleLabel,
  });

  static String disp(dynamic v) {
    if (v == null) return '—';
    if (v is bool) return v ? 'Yes' : 'No';
    if (v is Timestamp) {
      final d = v.toDate().toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    if (v is DateTime) {
      return DateFormat('dd MMMM yyyy, hh:mm a').format(v.toLocal());
    }
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return '—';
      try {
        if (t.length >= 10 && (t.contains('T') || RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(t))) {
          final d = DateTime.parse(t).toLocal();
          final datePart = DateFormat('dd MMMM yyyy').format(d);
          final hasTime = t.contains('T') && (d.hour != 0 || d.minute != 0 || d.second != 0);
          if (hasTime) {
            return '$datePart, ${DateFormat('hh:mm a').format(d)}';
          }
          return datePart;
        }
      } catch (_) {}
      return t;
    }
    final s = v.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.goldPrimary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
      ),
    ]);
  }

  Widget _row(String label, String value, {bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSubText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: boldValue ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop: two simple label/value pairs on one line (same typography as [_row]).
  Widget _desktopTwoFieldRow(
    String label1,
    String value1,
    String label2,
    String value2, {
    bool bold1 = false,
    bool bold2 = false,
  }) {
    Widget half(String label, String value, {bool boldValue = false}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSubText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: boldValue ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.lightText,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: half(label1, value1, boldValue: bold1)),
          const SizedBox(width: 20),
          Expanded(child: half(label2, value2, boldValue: bold2)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: AppColors.lightBorder);

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(children: children),
    );
  }

  List<Widget> _orderedScalarRows(
    Map<String, dynamic> scalarMap, {
    required bool desktop,
  }) {
    final ordered = orderedModuleHubScalarKeys(scalarMap);
    final rows = <Widget>[];
    if (!desktop) {
      for (final k in ordered) {
        if (rows.isNotEmpty) rows.add(_divider());
        rows.add(_row(_labelForRecordKey(k), disp(scalarMap[k])));
      }
      return rows;
    }
    for (var i = 0; i < ordered.length; i += 2) {
      if (rows.isNotEmpty) rows.add(_divider());
      final k1 = ordered[i];
      if (i + 1 < ordered.length) {
        final k2 = ordered[i + 1];
        rows.add(_desktopTwoFieldRow(
          _labelForRecordKey(k1),
          disp(scalarMap[k1]),
          _labelForRecordKey(k2),
          disp(scalarMap[k2]),
        ));
      } else {
        rows.add(_row(_labelForRecordKey(k1), disp(scalarMap[k1])));
      }
    }
    return rows;
  }

  Widget _extraFieldsSection(Map<String, dynamic> extra, {required bool desktop}) {
    if (extra.isEmpty) {
      return const SizedBox.shrink();
    }
    final keys = extra.keys.map((k) => k.toString()).toList();
    final blocks = <Widget>[];
    final scalarPending = <Widget>[];

    void flushScalars() {
      if (scalarPending.isEmpty) return;
      if (!desktop) {
        blocks.addAll(scalarPending);
      } else {
        for (var i = 0; i < scalarPending.length; i += 2) {
          if (i + 1 < scalarPending.length) {
            blocks.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: scalarPending[i]),
                    const SizedBox(width: 12),
                    Expanded(child: scalarPending[i + 1]),
                  ],
                ),
              ),
            );
          } else {
            blocks.add(scalarPending[i]);
          }
        }
      }
      scalarPending.clear();
    }

    for (final k in keys) {
      final v = extra[k];
      if (v is Map || v is List) {
        flushScalars();
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _row(_labelForRecordKey(k), '', boldValue: true),
                  ..._flattenForNested(v, desktop: desktop),
                ],
              ),
            ),
          ),
        );
      } else {
        final card = Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _card(children: [
            _row(_labelForRecordKey(k), disp(v)),
          ]),
        );
        if (!desktop) {
          blocks.add(card);
        } else {
          scalarPending.add(card);
        }
      }
    }
    flushScalars();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Extended & additional fields', Icons.extension_outlined),
        const SizedBox(height: 10),
        ...blocks,
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  List<Widget> _flattenForNested(dynamic v, {required bool desktop}) {
    final rows = <Widget>[];
    void addDividerBefore() {
      if (rows.isNotEmpty) rows.add(_divider());
    }

    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      final keys = m.keys.map((k) => k.toString()).toList();
      if (!desktop) {
        for (final k in keys) {
          addDividerBefore();
          final val = m[k];
          if (val is Map || val is List) {
            rows.add(_row(_labelForRecordKey(k), '', boldValue: true));
            rows.addAll(_flattenForNested(val, desktop: desktop));
          } else {
            rows.add(_row(_labelForRecordKey(k), disp(val)));
          }
        }
        return rows;
      }

      final pendingScalar = <({String label, String value})>[];
      void flushPendingScalars() {
        if (pendingScalar.isEmpty) return;
        for (var i = 0; i < pendingScalar.length; i += 2) {
          addDividerBefore();
          final a = pendingScalar[i];
          if (i + 1 < pendingScalar.length) {
            final b = pendingScalar[i + 1];
            rows.add(_desktopTwoFieldRow(a.label, a.value, b.label, b.value));
          } else {
            rows.add(_row(a.label, a.value));
          }
        }
        pendingScalar.clear();
      }

      for (final k in keys) {
        final val = m[k];
        if (val is Map || val is List) {
          flushPendingScalars();
          addDividerBefore();
          rows.add(_row(_labelForRecordKey(k), '', boldValue: true));
          rows.addAll(_flattenForNested(val, desktop: desktop));
        } else {
          pendingScalar.add((label: _labelForRecordKey(k), value: disp(val)));
        }
      }
      flushPendingScalars();
      return rows;
    }
    if (v is List) {
      if (!desktop) {
        for (var i = 0; i < v.length; i++) {
          addDividerBefore();
          final item = v[i];
          if (item is Map) {
            rows.add(_row('Item #${i + 1}', '', boldValue: true));
            rows.addAll(_flattenForNested(item, desktop: desktop));
          } else {
            rows.add(_row('#${i + 1}', disp(item)));
          }
        }
        return rows;
      }

      for (var i = 0; i < v.length; i++) {
        addDividerBefore();
        final item = v[i];
        if (item is Map) {
          rows.add(_row('Item #${i + 1}', '', boldValue: true));
          rows.addAll(_flattenForNested(item, desktop: desktop));
        } else {
          if (i + 1 < v.length && v[i + 1] is! Map) {
            rows.add(_desktopTwoFieldRow(
              '#${i + 1}',
              disp(item),
              '#${i + 2}',
              disp(v[i + 1]),
            ));
            i++;
          } else {
            rows.add(_row('#${i + 1}', disp(item)));
          }
        }
      }
      return rows;
    }
    addDividerBefore();
    rows.add(_row('Value', disp(v)));
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final raw = Map<String, dynamic>.from(record.toMap());
    final extra = raw['extraFields'] != null
        ? Map<String, dynamic>.from(raw['extraFields'] as Map? ?? {})
        : <String, dynamic>{};
    raw.remove('extraFields');

    Map<String, dynamic>? commonFormMap;
    final extraSansCommon = Map<String, dynamic>.from(extra);
    final nested = extra[kCommonFormExtraFieldsKey];
    if (nested is Map) {
      commonFormMap = Map<String, dynamic>.from(nested);
      extraSansCommon.remove(kCommonFormExtraFieldsKey);
    }

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final desktop =
            constraints.maxWidth > _kCaseDetailDesktopBreakpoint;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Module', Icons.category_outlined),
            const SizedBox(height: 10),
            _card(children: [
              _row('Dashboard module', moduleLabel, boldValue: true),
            ]),
            const SizedBox(height: AppSpacing.lg),
            if (commonFormMap == null) ...[
              _sectionHeader('All saved case fields', Icons.fact_check_outlined),
              const SizedBox(height: 10),
              _card(
                  children:
                      _orderedScalarRows(raw, desktop: desktop)),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (commonFormMap != null) ...[
              CommonFormDocumentView(
                commonMap: commonFormMap,
                extraMap: extraSansCommon,
              ),
            ] else if (extra.isNotEmpty) ...[
              _extraFieldsSection(extra, desktop: desktop),
            ],
            const SizedBox(height: 100),
          ],
        );
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _kCaseDetailDesktopBreakpoint) {
          return body;
        }
        return Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: _kCaseDetailMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kCaseDetailDesktopHorizontalPadding,
              ),
              child: body,
            ),
          ),
        );
      },
    );
  }
}
