// lib/widgets/common_form_document_view.dart
// Read-only UI: mirrors [CommonFormState.buildDocumentMap] §1–§17 + dynamic [extraMap]
// (same contract as common_form_pdf). Category-specific keys in [extraMap] render automatically.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import 'ad_form_dynamic_document_view.dart' show humanizeFieldKey;

/// Matches PDF / form: plain string with fallback.
String _v(dynamic v, {String or = ''}) {
  if (v == null) return or;
  final s = v.toString().trim();
  return s.isEmpty ? or : s;
}

String _labelifyExtraKey(String key) {
  var result = key.replaceAll('_', ' ');
  result = result.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  if (result.isEmpty) return key;
  return result[0].toUpperCase() + result.substring(1);
}

String _disp(dynamic v) {
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
      if (t.length >= 10 &&
          (t.contains('T') || RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(t))) {
        final d = DateTime.parse(t).toLocal();
        final datePart = DateFormat('dd MMMM yyyy').format(d);
        final hasTime = t.contains('T') &&
            (d.hour != 0 || d.minute != 0 || d.second != 0);
        if (hasTime) {
          return '$datePart, ${DateFormat('hh:mm a').format(d)}';
        }
        return datePart;
      }
    } catch (_) {}
    return t;
  }
  if (v is List) {
    if (v.isEmpty) return '—';
    return v.map(_disp).join(', ');
  }
  if (v is Map) {
    if (v.isEmpty) return '—';
    return v.entries
        .map((e) => '${_labelifyExtraKey(e.key.toString())}: ${_disp(e.value)}')
        .join(' · ');
  }
  final s = v.toString().trim();
  return s.isEmpty ? '—' : s;
}

/// Matches [module_record_dynamic_document_view.dart] case-detail breakpoint.
const double _kCaseDetailDesktopBreakpoint = 800;

class _CaseDetailLayoutScope extends InheritedWidget {
  const _CaseDetailLayoutScope({
    required this.desktop,
    required super.child,
  });

  final bool desktop;

  static bool isDesktop(BuildContext context) {
    final w =
        context.dependOnInheritedWidgetOfExactType<_CaseDetailLayoutScope>();
    return w?.desktop ?? false;
  }

  @override
  bool updateShouldNotify(_CaseDetailLayoutScope oldWidget) =>
      oldWidget.desktop != desktop;
}

const Map<String, String> _kProcLabels = {
  'chkMemo': 'Memorandum Panchanama',
  'chkPanchSpot': 'Panchanama Spot',
  'chkInquest': 'Inquest',
  'chkIdent': 'Identification',
  'chkSearch': 'Search',
  'chkPersSearch': 'Personal Search',
  'chkIdParade': 'Identification Parade',
  'chkExhumation': 'Exhumation',
};

class CommonFormDocumentView extends StatelessWidget {
  const CommonFormDocumentView({
    super.key,
    required this.commonMap,
    this.extraMap = const {},
  });

  final Map<String, dynamic> commonMap;
  final Map<String, dynamic> extraMap;

  Widget _sectionTitle(String title, IconData icon, Color accent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 10),
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
      ],
    );
  }

  Widget _numSectionHeader(int num, String title, Color accent) {
    return Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: accent,
          child: Text(
            '$num',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 0.5, color: AppColors.lightBorder);

  Widget _row(String label, String value, {bool fullWidth = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: fullWidth ? 1 : 2,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSubText,
                letterSpacing: 0.4,
              ),
            ),
          ),
          if (!fullWidth)
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText,
                ),
              ),
            ),
          if (fullWidth)
            Expanded(
              flex: 4,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _compactLabelValue(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSubText,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _desktopTwoSimpleFieldsRow(
    String l1,
    String v1,
    String l2,
    String v2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _compactLabelValue(l1, v1)),
          const SizedBox(width: 16),
          Expanded(child: _compactLabelValue(l2, v2)),
        ],
      ),
    );
  }

  /// Desktop: pairs consecutive non-[fullWidth] fields into two columns.
  List<Widget> _pairedSimpleFields(
    BuildContext context,
    List<({String label, String value, bool fullWidth})> fields,
  ) {
    final desktop = _CaseDetailLayoutScope.isDesktop(context);
    final out = <Widget>[];
    if (!desktop) {
      for (var i = 0; i < fields.length; i++) {
        if (i > 0) out.add(_divider());
        final f = fields[i];
        out.add(_row(f.label, f.value, fullWidth: f.fullWidth));
      }
      return out;
    }
    for (var i = 0; i < fields.length; i++) {
      final f = fields[i];
      if (f.fullWidth) {
        if (out.isNotEmpty) out.add(_divider());
        out.add(_row(f.label, f.value, fullWidth: true));
        continue;
      }
      if (i + 1 < fields.length && !fields[i + 1].fullWidth) {
        final g = fields[i + 1];
        if (out.isNotEmpty) out.add(_divider());
        out.add(_desktopTwoSimpleFieldsRow(f.label, f.value, g.label, g.value));
        i++;
      } else {
        if (out.isNotEmpty) out.add(_divider());
        out.add(_row(f.label, f.value, fullWidth: false));
      }
    }
    return out;
  }

  Widget _surfaceCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _sectionShell(
    int idx,
    String title,
    Color accent,
    List<Widget> body, {
    IconData icon = Icons.article_outlined,
  }) {
    return _surfaceCard([
      idx > 0
          ? _numSectionHeader(idx, title, accent)
          : _sectionTitle(title, icon, accent),
      _divider(),
      ...body,
    ]);
  }

  Widget _mutedNote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: AppColors.lightSubText,
        ),
      ),
    );
  }

  Widget _personCard(BuildContext context, String heading, Map<String, dynamic> p) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: const Border(
          left: BorderSide(color: AppColors.infoBlue, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          _divider(),
          ..._pairedSimpleFields(context, [
            (label: 'Name', value: _v(p['name']), fullWidth: false),
            (label: 'Age', value: _v(p['age']), fullWidth: false),
            (label: 'Gender', value: _v(p['gender']), fullWidth: false),
            (label: 'Occupation', value: _v(p['occ']), fullWidth: false),
            (label: 'Mobile', value: _v(p['mobile']), fullWidth: false),
            (label: 'Aadhaar', value: _v(p['aadhaar']), fullWidth: false),
            (label: 'Religion', value: _v(p['religion']), fullWidth: false),
            (label: 'Caste', value: _v(p['caste']), fullWidth: false),
            (label: 'PAN', value: _v(p['pan']), fullWidth: false),
          ]),
        ],
      ),
    );
  }

  Widget _chargeCard(int n, Map<dynamic, dynamic> data) {
    final act = _v(data['act']);
    final secs = (data['sections'] as List?)?.map((s) => s.toString()).toList() ?? [];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: const Border(
          left: BorderSide(color: AppColors.infoBlue, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charge #$n${act.isEmpty ? '' : ': $act'}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          if (secs.isEmpty)
            Text(
              'No sections selected',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.lightSubText),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: secs
                  .map(
                    (s) => Chip(
                      label: Text('§$s'),
                      visualDensity: VisualDensity.compact,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(color: AppColors.infoBlue.withValues(alpha: 0.5)),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _verdictColumn(String title, List<String> names, Color edge) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: edge.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: edge,
              ),
            ),
            _divider(),
            if (names.isEmpty)
              Text(
                'None',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.lightSubText,
                ),
              )
            else
              ...names.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: edge),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          n,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.lightText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _scrutinyStepUi(
    BuildContext context,
    int step,
    String title,
    bool active, {
    required String send,
    required String grant,
    String? lockedMsg,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: active ? AppColors.infoBlue : AppColors.lightBorder,
                child: Text(
                  '$step',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: active ? AppColors.infoBlue : AppColors.lightBorder,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.navyDark : AppColors.lightSubText,
                  ),
                ),
                const SizedBox(height: 6),
                if (!active && lockedMsg != null)
                  Text(
                    lockedMsg,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: AppColors.lightSubText,
                    ),
                  )
                else ...[
                  ..._pairedSimpleFields(context, [
                    (label: 'Send Date', value: send, fullWidth: false),
                    (label: 'Grant Date', value: grant, fullWidth: false),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicNested(BuildContext context, dynamic v) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._flattenDynamic(context, v),
        ],
      ),
    );
  }

  List<Widget> _flattenDynamic(BuildContext context, dynamic v) {
    final rows = <Widget>[];
    final desktop = _CaseDetailLayoutScope.isDesktop(context);

    void addDivider() {
      if (rows.isNotEmpty) rows.add(_divider());
    }

    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      final keys = m.keys.toList();
      if (!desktop) {
        for (final k in keys) {
          addDivider();
          final val = m[k];
          if (val is Map || val is List) {
            rows.add(Text(
              humanizeFieldKey(k),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ));
            rows.addAll(_flattenDynamic(context, val));
          } else {
            rows.add(_row(humanizeFieldKey(k), _disp(val)));
          }
        }
        return rows;
      }

      final pending = <({String label, String value})>[];
      void flushScalars() {
        if (pending.isEmpty) return;
        for (var i = 0; i < pending.length; i += 2) {
          addDivider();
          final a = pending[i];
          if (i + 1 < pending.length) {
            final b = pending[i + 1];
            rows.add(_desktopTwoSimpleFieldsRow(a.label, a.value, b.label, b.value));
          } else {
            rows.add(_row(a.label, a.value));
          }
        }
        pending.clear();
      }

      for (final k in keys) {
        final val = m[k];
        if (val is Map || val is List) {
          flushScalars();
          addDivider();
          rows.add(Text(
            humanizeFieldKey(k),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ));
          rows.addAll(_flattenDynamic(context, val));
        } else {
          pending.add((label: humanizeFieldKey(k), value: _disp(val)));
        }
      }
      flushScalars();
      return rows;
    }

    if (v is List) {
      if (v.isEmpty) {
        rows.add(Text('—',
            style: GoogleFonts.poppins(color: AppColors.lightSubText)));
        return rows;
      }
      if (!desktop) {
        for (var i = 0; i < v.length; i++) {
          addDivider();
          final item = v[i];
          if (item is Map) {
            rows.add(Text(
              'Entry #${i + 1}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.navyMid,
                fontSize: 12,
              ),
            ));
            rows.addAll(_flattenDynamic(context, Map<String, dynamic>.from(item)));
          } else {
            rows.add(_row('#${i + 1}', _disp(item)));
          }
        }
        return rows;
      }

      for (var i = 0; i < v.length; i++) {
        addDivider();
        final item = v[i];
        if (item is Map) {
          rows.add(Text(
            'Entry #${i + 1}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.navyMid,
              fontSize: 12,
            ),
          ));
          rows.addAll(_flattenDynamic(context, Map<String, dynamic>.from(item)));
        } else {
          if (i + 1 < v.length && v[i + 1] is! Map) {
            rows.add(_desktopTwoSimpleFieldsRow(
              '#${i + 1}',
              _disp(item),
              '#${i + 2}',
              _disp(v[i + 1]),
            ));
            i++;
          } else {
            rows.add(_row('#${i + 1}', _disp(item)));
          }
        }
      }
      return rows;
    }

    rows.add(Text(_disp(v),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.lightText)));
    return rows;
  }

  List<Widget> _buildExtraMapSection(BuildContext context) {
    if (extraMap.isEmpty) return [];

    final flat = <MapEntry<String, dynamic>>[];
    final nested = <MapEntry<String, dynamic>>[];
    for (final e in extraMap.entries) {
      if (e.value is Map) {
        nested.add(e);
      } else {
        flat.add(e);
      }
    }

    final out = <Widget>[];
    final desktop = _CaseDetailLayoutScope.isDesktop(context);

    if (flat.isNotEmpty) {
      if (!desktop) {
        out.add(_surfaceCard([
          for (var i = 0; i < flat.length; i++) ...[
            if (i > 0) _divider(),
            _row(_labelifyExtraKey(flat[i].key), _disp(flat[i].value)),
          ],
        ]));
      } else {
        final flatRows = <Widget>[];
        for (var i = 0; i < flat.length; i += 2) {
          if (flatRows.isNotEmpty) flatRows.add(_divider());
          if (i + 1 < flat.length) {
            flatRows.add(_desktopTwoSimpleFieldsRow(
              _labelifyExtraKey(flat[i].key),
              _disp(flat[i].value),
              _labelifyExtraKey(flat[i + 1].key),
              _disp(flat[i + 1].value),
            ));
          } else {
            flatRows.add(
                _row(_labelifyExtraKey(flat[i].key), _disp(flat[i].value)));
          }
        }
        out.add(_surfaceCard(flatRows));
      }
    }

    for (final e in nested) {
      out.add(_buildDynamicNested(context, e.value));
    }

    out.add(const SizedBox(height: AppSpacing.lg));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        final wide =
            constraints.maxWidth > _kCaseDetailDesktopBreakpoint;
        return _CaseDetailLayoutScope(
          desktop: wide,
          child: Builder(
            builder: (context) => _buildDetailColumn(context),
          ),
        );
      },
    );
  }

  Widget _buildDetailColumn(BuildContext context) {
    final m = commonMap;
    final isUnknown = m['isUnknownUntraced'] == true;
    final charges = m['charges'] as Map? ?? {};
    final comp = m['complainant'] as Map? ?? {};
    final u = m['unidentified'] as Map? ?? {};
    final cr8 = m['caseResponsibility'] as Map? ?? {};
    final procChecks = m['proceduralChecks'] as Map? ?? {};
    final procDates = m['proceduralDates'] as Map? ?? {};
    final seizures = (m['seizures'] as List?) ?? [];
    final prev = m['preventive'] as Map? ?? {};
    final discharge = (m['dischargeByAccused'] as Map?) ?? {};
    final court = m['court'] as Map? ?? {};
    final verdict = m['verdict'] as Map? ?? {};
    final acquitted =
        (verdict['acquitted'] as List?)?.map((x) => x.toString()).toList() ?? [];
    final convicted =
        (verdict['convicted'] as List?)?.map((x) => x.toString()).toList() ?? [];
    final sc = m['scrutiny'] as Map? ?? {};
    final accusedList = (m['accused'] as List?) ?? [];
    final suspectedList = (m['suspectedAccused'] as List?) ?? [];
    final arrests = (m['arrestRelease'] as List?) ?? [];

    final accent = AppColors.infoBlue;

    final children = <Widget>[
      _sectionTitle(
        'Crime registration (full Common Form)',
        Icons.fact_check_outlined,
        AppColors.goldPrimary,
      ),
      const SizedBox(height: 10),
      _sectionShell(
        1,
        'CRIME REGISTRATION INFO',
        accent,
        _pairedSimpleFields(context, [
          (label: 'Cr. No.', value: _v(m['crNo']), fullWidth: false),
          (label: 'Registered Date', value: _v(m['regDate']), fullWidth: false),
          (label: 'Unknown / Untraced', value: isUnknown ? 'Yes' : 'No', fullWidth: false),
          (label: 'FIR Copy', value: _v(m['firCopyPath'], or: 'Not uploaded'), fullWidth: false),
        ]),
      ),
      _sectionShell(
        2,
        'ACTS & SECTIONS FILED',
        accent,
        [
          if (charges.isEmpty)
            Text('No charges added.',
                style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightSubText))
          else
            ...charges.entries.toList().asMap().entries.map((e) {
              final i = e.key + 1;
              final data = e.value.value as Map? ?? {};
              return _chargeCard(i, data);
            }),
        ],
      ),
      _sectionShell(
        3,
        'CRIME SPOT',
        accent,
        _pairedSimpleFields(context, [
          (label: 'Village / Town', value: _v(m['spotVillage']), fullWidth: false),
          (label: 'Area Name', value: _v(m['spotArea']), fullWidth: false),
          (label: 'Full Address', value: _v(m['spotAddress']), fullWidth: true),
        ]),
      ),
      ..._buildExtraMapSection(context),
      _sectionShell(
        4,
        'COMPLAINANT KYC',
        accent,
        [
          if (comp.isEmpty)
            Text('No complainant data.',
                style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightSubText))
          else ...[
            ..._pairedSimpleFields(context, [
              (label: 'Name', value: _v(comp['name']), fullWidth: false),
              (label: 'Age', value: _v(comp['age']), fullWidth: false),
              (label: 'Gender', value: _v(comp['gender']), fullWidth: false),
              (label: 'Occupation', value: _v(comp['occ']), fullWidth: false),
              (label: 'Mobile', value: _v(comp['mobile']), fullWidth: false),
              (label: 'Aadhaar', value: _v(comp['aadhaar']), fullWidth: false),
              (label: 'Religion', value: _v(comp['religion']), fullWidth: false),
              (label: 'Caste', value: _v(comp['caste']), fullWidth: false),
              (label: 'PAN Number', value: _v(comp['pan']), fullWidth: false),
            ]),
          ],
        ],
      ),
      _sectionShell(
        5,
        'ACCUSED DETAILS',
        accent,
        [
          if (isUnknown)
            _mutedNote('Unknown / Untraced — accused list suppressed in form.'),
          if (!isUnknown)
            accusedList.isEmpty
                ? Text('No accused added.',
                    style: GoogleFonts.poppins(
                        fontStyle: FontStyle.italic,
                        color: AppColors.lightSubText))
                : Column(
                    children: accusedList.asMap().entries.map((e) {
                      return _personCard(
                        context,
                        'Accused #${e.key + 1}',
                        Map<String, dynamic>.from(e.value as Map),
                      );
                    }).toList(),
                  ),
        ],
      ),
      _sectionShell(
        6,
        'SUSPECTED ACCUSED',
        accent,
        [
          if (isUnknown)
            _mutedNote('Hidden when Unknown/Untraced is ON.'),
          if (!isUnknown)
            suspectedList.isEmpty
                ? Text('No suspected accused added.',
                    style: GoogleFonts.poppins(
                        fontStyle: FontStyle.italic,
                        color: AppColors.lightSubText))
                : Column(
                    children: suspectedList.asMap().entries.map((e) {
                      return _personCard(
                        context,
                        'Suspected #${e.key + 1}',
                        Map<String, dynamic>.from(e.value as Map),
                      );
                    }).toList(),
                  ),
        ],
      ),
      _sectionShell(
        7,
        'UNIDENTIFIED CRIMINAL DESCRIPTION',
        Colors.orange,
        [
          if (!isUnknown)
            _mutedNote(
                'Known accused mode — unidentified block still reflects saved values.'),
          if (isUnknown) _mutedNote('Unknown/Untraced — fill all applicable fields.'),
          ..._pairedSimpleFields(context, [
            (label: 'Gender', value: _v(u['gender']), fullWidth: false),
            (label: 'Approx Age', value: _v(u['approxAge']), fullWidth: false),
            (label: 'Skin Color', value: _v(u['skinColor']), fullWidth: false),
            (label: 'Approx Height', value: _v(u['approxHeight']), fullWidth: false),
            (label: 'Mobile (if known)', value: _v(u['mobile']), fullWidth: false),
            (label: 'Occupation (possible)', value: _v(u['occupation']), fullWidth: false),
            (label: 'Last Known Address', value: _v(u['lastKnownAddress']), fullWidth: true),
            (label: 'Other Physical Markers', value: _v(u['otherPhysicalMarkers']), fullWidth: true),
          ]),
        ],
      ),
      _sectionShell(
        8,
        'CASE RESPONSIBILITY',
        accent,
        _pairedSimpleFields(context, [
          (label: 'IO Designation', value: _v(cr8['ioDesig']), fullWidth: false),
          (label: 'IO Name', value: _v(cr8['ioName']), fullWidth: false),
          (label: 'Reg. By Desig.', value: _v(cr8['regDesig']), fullWidth: false),
          (label: 'Registrar Name', value: _v(cr8['regName']), fullWidth: false),
          (label: 'CCTV', value: _v(cr8['cctvValue'], or: 'Not set'), fullWidth: false),
          (label: 'CCTV Date & Time', value: _v(cr8['cctvDateTime']), fullWidth: false),
        ]),
      ),
      _sectionShell(
        9,
        'ARREST & RELEASE STATUS',
        accent,
        [
          if (arrests.isEmpty)
            Text('No arrest records.',
                style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightSubText))
          else
            ...arrests.map((r) {
              final row = r as Map;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(children: [
                  ..._pairedSimpleFields(context, [
                    (label: 'Name', value: _v(row['accusedName']), fullWidth: false),
                    (label: 'Arrest Date/Time', value: _v(row['arrestDt']), fullWidth: false),
                    (label: 'Release Type', value: _v(row['releaseType']), fullWidth: false),
                    (label: 'Release Date', value: _v(row['releaseDt']), fullWidth: false),
                  ]),
                ]),
              );
            }),
        ],
      ),
      _sectionShell(
        10,
        'PROCEDURAL DETAILS',
        accent,
        [
          ..._kProcLabels.entries.map((e) {
            final on = procChecks[e.key] == true;
            final raw = procDates[e.key]?.toString().trim() ?? '';
            final dl = raw.isEmpty ? '—' : raw;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        on ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 22,
                        color: on ? AppColors.infoBlue : AppColors.lightSubText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${e.value} (${on ? 'checked' : 'unchecked'})',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: on ? AppColors.navyDark : AppColors.lightSubText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 4),
                    child: Text(
                      'Date (proceduralDates.${e.key}): $dl',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.lightSubText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          _row('E-shaksh', _v(m['eshakshValue'], or: 'Not set')),
        ],
      ),
      _sectionShell(
        11,
        'SEIZURE RECORDS',
        accent,
        [
          if (seizures.isEmpty)
            Text('No seizure records.',
                style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightSubText))
          else
            ...seizures.asMap().entries.map((e) {
              final s = e.value as Map;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(children: [
                  ..._pairedSimpleFields(context, [
                    (
                      label: 'Property Description',
                      value: _v(s['desc']),
                      fullWidth: true
                    ),
                    (label: 'Seized From', value: _v(s['fromWhom'], or: '—'), fullWidth: false),
                    (label: 'Other Name', value: _v(s['otherName']), fullWidth: false),
                  ]),
                ]),
              );
            }),
        ],
      ),
      _sectionShell(
        12,
        'TECHNICAL & CUSTODY',
        accent,
        _pairedSimpleFields(context, [
          (label: 'CDR Sent Date', value: _v(m['cdrSent']), fullWidth: false),
          (label: 'CDR Received Date', value: _v(m['cdrRecv']), fullWidth: false),
          (label: 'PCR (Days)', value: _v(m['pcrDays']), fullWidth: false),
          (label: 'MCR (Days)', value: _v(m['mcrDays']), fullWidth: false),
        ]),
      ),
      _sectionShell(
        13,
        'PREVENTIVE & BONDS',
        accent,
        _pairedSimpleFields(context, [
          (label: 'Preventive Action', value: _v(prev['action'], or: 'Not set'), fullWidth: false),
          (label: 'Outward Number', value: _v(prev['outwardNumber']), fullWidth: false),
          (label: 'Bond Date', value: _v(prev['bondDate']), fullWidth: false),
          (label: 'Bond Cancellation Date', value: _v(prev['bondCancellation']), fullWidth: false),
        ]),
      ),
      _sectionShell(
        14,
        'DISCHARGE STATUS',
        accent,
        [
          if (discharge.isEmpty)
            Text('No discharge data.',
                style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightSubText))
          else
            ...discharge.entries.map((e) {
              final ok = e.value == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      ok ? Icons.check_circle : Icons.cancel_outlined,
                      size: 20,
                      color: ok ? AppColors.successGreen : AppColors.lightSubText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${e.key} — ${ok ? 'Discharged' : 'Not discharged'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: ok ? AppColors.navyDark : AppColors.lightSubText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
      _sectionShell(
        15,
        'COURT FILING',
        accent,
        _pairedSimpleFields(context, [
          (label: 'Charge Sheet No.', value: _v(court['chargeSheetNumber']), fullWidth: false),
          (label: 'CC / ST Number', value: _v(court['ccStNumber']), fullWidth: false),
          (label: 'Final Summary', value: _v(court['finalSummary'], or: 'Not set'), fullWidth: false),
          (label: 'Quashed by High Court', value: _v(court['quashedHighCourt']), fullWidth: false),
        ]),
      ),
      _sectionShell(
        16,
        'FINAL VERDICT',
        accent,
        [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _verdictColumn(
                  '✓ ACQUITTED', acquitted, AppColors.successGreen),
              const SizedBox(width: 10),
              _verdictColumn('✗ CONVICTED', convicted, AppColors.dangerRed),
            ],
          ),
        ],
      ),
      _sectionShell(
        17,
        'CASE SCRUTINY PIPELINE',
        accent,
        [
          _scrutinyStepUi(context, 1, 'SDPO / ACP Approval', true,
              send: _v(sc['sdpoSend']), grant: _v(sc['sdpoGrant'])),
          _scrutinyStepUi(
            context,
            2,
            'APP Scrutiny',
            sc['stepAppActive'] == true,
            send: _v(sc['appSend']),
            grant: _v(sc['appGrant']),
            lockedMsg: 'Unlocks when SDPO Send Date is filled',
          ),
          _scrutinyStepUi(
            context,
            3,
            'Addl SP / DCP / Addl CP',
            sc['stepDcpActive'] == true,
            send: _v(sc['dcpSend']),
            grant: _v(sc['dcpGrant']),
            lockedMsg: 'Unlocks when APP Send Date is filled',
            isLast: true,
          ),
          const SizedBox(height: 8),
          ..._pairedSimpleFields(context, [
            (
              label: 'stepAppActive (scrutiny)',
              value: sc['stepAppActive'] == true ? 'Yes' : 'No',
              fullWidth: false
            ),
            (
              label: 'stepDcpActive (scrutiny)',
              value: sc['stepDcpActive'] == true ? 'Yes' : 'No',
              fullWidth: false
            ),
          ]),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
