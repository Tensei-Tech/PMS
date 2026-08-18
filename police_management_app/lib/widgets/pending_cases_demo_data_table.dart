// lib/widgets/pending_cases_demo_data_table.dart
// Shared pending demo [Table] — same layout as [PendingDemoTableScreen].

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

const List<Map<String, String>> kPendingDemoTableRows = [
  {
    'sr': '1',
    'cr': '123/2024',
    'sections': '302 IPC',
    'date': '15/01/2024',
    'io': 'PSI Sharma',
    'spot': 'Main Bazar',
    'reason': 'Witness not available',
    'period': 'More than 1 year',
    'head': 'Murder',
  },
  {
    'sr': '2',
    'cr': '456/2024',
    'sections': '379 IPC',
    'date': '20/03/2024',
    'io': 'PSI Verma',
    'spot': 'Highway No.7',
    'reason': 'Accused absconding',
    'period': '6 to 12 months',
    'head': 'Theft',
  },
  {
    'sr': '3',
    'cr': '789/2024',
    'sections': '420 IPC',
    'date': '10/06/2024',
    'io': 'PSI Patil',
    'spot': 'Near Station',
    'reason': 'Document pending',
    'period': '3 to 6 months',
    'head': 'Cheating',
  },
  {
    'sr': '4',
    'cr': '321/2025',
    'sections': '376 IPC',
    'date': '05/09/2024',
    'io': 'PSI Khan',
    'spot': 'Market Area',
    'reason': 'Medical report awaited',
    'period': 'More than 3 months',
    'head': 'Rape',
  },
  {
    'sr': '5',
    'cr': '654/2025',
    'sections': '307 IPC',
    'date': '12/11/2024',
    'io': 'PSI Desai',
    'spot': 'Old City',
    'reason': 'FSL report pending',
    'period': 'Within 3 months',
    'head': 'Attempt to Murder',
  },
  {
    'sr': '6',
    'cr': '987/2025',
    'sections': '323 IPC',
    'date': '01/04/2025',
    'io': 'PSI Joshi',
    'spot': '',
    'reason': 'Complainant not present',
    'period': '1 month',
    'head': 'Hurt',
  },
];

bool _liveRowsInUse(List<Map<String, String>>? real) =>
    real != null && real.isNotEmpty;

/// Same appearance as the table inside [PendingDemoTableScreen.build].
///
/// When [exclusiveLiveFirestoreData] is true, [realDataRows] is used exclusively
/// (including when empty — no demo substitution).
///
/// Otherwise: when [realDataRows] is non-null and non-empty, it wins; then [fallbackRows]
/// when non-null; else [kPendingDemoTableRows].
class PendingCasesDemoDataTable extends StatelessWidget {
  const PendingCasesDemoDataTable({
    super.key,
    required this.isAd,
    this.realDataRows,
    this.fallbackRows,
    this.serialOffset = 0,
    this.includeDemoDisclaimerBelowTable = true,
    this.exclusiveLiveFirestoreData = false,
  });

  final bool isAd;

  /// Firestore/live rows mapped for the pending table columns.
  final List<Map<String, String>>? realDataRows;

  /// When live data is unavailable, non-null lists are shown as-is (may be empty).
  /// Null means fall back to [kPendingDemoTableRows].
  final List<Map<String, String>>? fallbackRows;

  /// Row `i` shows Sr. No = [serialOffset] + i + 1.
  final int serialOffset;

  /// Screen-level disclaimers often preferred when multiple tables are stacked (Summary).
  final bool includeDemoDisclaimerBelowTable;

  /// When true, demo rows never replace an empty Firestore-derived list (see [_effectiveRows]).
  final bool exclusiveLiveFirestoreData;

  List<Map<String, String>> _effectiveRows() {
    if (exclusiveLiveFirestoreData) {
      return realDataRows ?? [];
    }
    if (_liveRowsInUse(realDataRows)) return realDataRows!;
    if (fallbackRows != null) return fallbackRows!;
    return kPendingDemoTableRows;
  }

  bool get _showsDemoBackdrop =>
      !exclusiveLiveFirestoreData && !_liveRowsInUse(realDataRows);

  @override
  Widget build(BuildContext context) {
    final rows = _effectiveRows();
    final showDisclaimer = includeDemoDisclaimerBelowTable &&
        _showsDemoBackdrop &&
        rows.isNotEmpty;

    final tableCore = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final double cellFontSize =
            w < 360 ? 9.5 : (w < 420 ? 10.5 : 11.5);
        final double headerFontSize =
            w < 360 ? 9.5 : (w < 420 ? 10.5 : 11.5);

        final columnWidths = <int, TableColumnWidth>{
          0: const IntrinsicColumnWidth(),
          1: const FlexColumnWidth(1.3),
          2: const FlexColumnWidth(1.2),
          3: const FlexColumnWidth(1.3),
          4: const FlexColumnWidth(1.7),
          if (isAd) 5: const FlexColumnWidth(1.3),
          (isAd ? 6 : 5): const FlexColumnWidth(2.6),
          (isAd ? 7 : 6): const FlexColumnWidth(1.4),
          (isAd ? 8 : 7): const FlexColumnWidth(1.2),
        };

        Widget headerCell(String s) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              color: AppColors.navyDark,
              alignment: Alignment.center,
              child: Text(
                s,
                textAlign: TextAlign.center,
                softWrap: true,
                style: GoogleFonts.poppins(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
            );

        Widget dataCell(String s, {Alignment align = Alignment.center}) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              alignment: align,
              child: Text(
                s,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.poppins(
                  fontSize: cellFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText,
                  height: 1.15,
                ),
              ),
            );

        final headers = <Widget>[
          headerCell('Sr. No'),
          headerCell('Cr. No.'),
          headerCell('Sections'),
          headerCell('Registered Date'),
          headerCell('Investigation Officer'),
          if (isAd) headerCell('Crime Spot'),
          headerCell('Reason for Pending'),
          headerCell('Time Period'),
          headerCell('Head'),
        ];

        TableRow rowFor(int idx, Map<String, String> r) {
          final bg =
              idx.isEven ? Colors.white : const Color(0xFFF6F8FF);
          return TableRow(
            decoration: BoxDecoration(color: bg),
            children: [
              dataCell('${serialOffset + idx + 1}'),
              dataCell(r['cr']!),
              dataCell(r['sections']!),
              dataCell(r['date']!),
              dataCell(r['io']!, align: Alignment.centerLeft),
              if (isAd) dataCell(r['spot'] ?? ''),
              dataCell(r['reason']!, align: Alignment.centerLeft),
              dataCell(r['period']!),
              dataCell(r['head']!),
            ],
          );
        }

        final maxH = constraints.maxHeight;
        final inner = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: maxH.isFinite ? maxH : null,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Table(
              columnWidths: columnWidths,
              defaultVerticalAlignment:
                  TableCellVerticalAlignment.middle,
              border: TableBorder.all(
                color: AppColors.lightBorder,
                width: 1,
              ),
              children: [
                TableRow(
                  decoration:
                      const BoxDecoration(color: AppColors.navyDark),
                  children: headers,
                ),
                for (var i = 0; i < rows.length; i++) rowFor(i, rows[i]),
              ],
            ),
          ),
        );
        if (maxH.isFinite) return inner;
        final estimatedRowPx = 44.0;
        final estHeight =
            estimatedRowPx * (rows.isEmpty ? 2 : rows.length + 1) + 16;
        return SizedBox(height: estHeight, child: inner);
      },
    );

    if (!showDisclaimer) return tableCore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        tableCore,
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '* Demo Data — Will be replaced with live data',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSubText,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}
