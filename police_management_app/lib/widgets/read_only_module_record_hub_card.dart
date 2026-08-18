// lib/widgets/read_only_module_record_hub_card.dart
// Read-only hub list card (View + PDF) — shared by Pending Records and IO Wise.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../modules/core/models/base_record.dart';
import '../screens/ad_record_detail_screen.dart';
import '../screens/module_record_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/module_pdf_helper.dart';

class ReadOnlyModuleRecordHubCard extends StatelessWidget {
  final ModuleRecord record;

  const ReadOnlyModuleRecordHubCard({super.key, required this.record});

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warningOrange;
      case 'Active':
        return AppColors.infoBlue;
      case 'Resolved':
        return AppColors.successGreen;
      case 'Closed':
        return const Color(0xFF607D8B);
      default:
        return AppColors.lightSubText;
    }
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(record.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(record.caseNumber,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.infoBlue)),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sc.withValues(alpha: 0.3)),
                  ),
                  child: Text(record.status,
                      style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: sc)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(record.title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark)),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  record.firestoreCategoryDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (record.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(record.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.lightSubText)),
              ],
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.person_rounded,
                    size: 13, color: AppColors.lightSubText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(record.assignedOfficer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.lightSubText)),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppColors.lightSubText),
                const SizedBox(width: 4),
                Text(DateFormat('dd MMM yyyy').format(record.incidentDate),
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.lightSubText)),
              ]),
            ]),
          ),
          Container(height: 1, color: AppColors.lightBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionBtn(Icons.visibility_rounded, 'View',
                    AppColors.goldPrimary, () {
                  Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(
                      page: record.moduleKey == 'ad'
                          ? AdRecordDetailScreen(record: record)
                          : ModuleRecordDetailScreen(record: record),
                    ),
                  );
                }),
                Container(width: 1, height: 24, color: AppColors.lightBorder),
                _actionBtn(Icons.picture_as_pdf_rounded, 'Download',
                    AppColors.dangerRed, () {
                  ModulePdfHelper.generatePdf(record);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
