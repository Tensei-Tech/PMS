// lib/screens/report_case_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../modules/core/models/base_record.dart';
import '../theme/app_theme.dart';
import 'ad_record_detail_screen.dart';
import 'module_record_detail_screen.dart';
import '../utils/module_pdf_helper.dart';
import '../utils/pdf_auth_gate.dart';

class ReportCaseListScreen extends StatelessWidget {
  final String title;
  final List<ModuleRecord> records;

  const ReportCaseListScreen({
    super.key,
    required this.title,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navyDark, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark)),
            Text('${records.length} records found',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.lightSubText)),
          ],
        ),
      ),
      body: records.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: records.length,
              itemBuilder: (context, i) => _buildCard(context, records[i]),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No records found for this category',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSubText)),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, ModuleRecord record) {
    final statusColor = _getStatusColor(record.status);
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
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(record.status,
                          style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(record.title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark)),
                const SizedBox(height: 4),
                Text(
                  record.firestoreCategoryDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.lightSubText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(record.location,
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
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.lightBorder),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionBtn(context, Icons.visibility_rounded, 'View', AppColors.goldPrimary, () {
                  Navigator.push(context, AppTheme.fadeSlideRoute(
                    page: record.moduleKey == 'ad'
                        ? AdRecordDetailScreen(
                            record: record,
                          )
                        : ModuleRecordDetailScreen(
                            record: record,
                          ),
                  ));
                }),
                Container(width: 1, height: 20, color: AppColors.lightBorder),
                _actionBtn(context, Icons.picture_as_pdf_rounded, 'PDF', AppColors.dangerRed, () {
                  runWithPdfAuthGate(
                    context,
                    () => ModulePdfHelper.generatePdf(record),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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
}
