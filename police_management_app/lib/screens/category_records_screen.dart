// lib/screens/category_records_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/module_registry.dart';
import '../modules/core/models/base_record.dart';
import '../theme/app_theme.dart';
import '../utils/pdf_helper.dart';
import '../utils/pdf_auth_gate.dart';
import 'case_form_screen.dart';
import 'case_detail_screen.dart';

class CategoryRecordsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryRecordsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final provider = getProvider(context, categoryName);
    final records = provider.records;

    final width = MediaQuery.of(context).size.width;
    final gridCols = width > 1200 ? 3 : (width > 800 ? 2 : 1);

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
        title: Text(
          '$categoryName Records',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                AppTheme.fadeSlideRoute(
                    page: CaseFormScreen(categoryName: categoryName)),
              );
            },
            icon: Icon(Icons.add_circle_rounded, color: AppColors.navyMid),
          ),
        ],
      ),
      body: records.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: records.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCols,
                mainAxisExtent: 180, // Approximate height for the unified card
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, i) =>
                  _buildRecordCard(context, records[i]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No records found for $categoryName',
            style: GoogleFonts.poppins(
              color: AppColors.lightSubText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, ModuleRecord record) {
    final statusColor = record.status == 'Open'
        ? AppColors.warningOrange
        : record.status == 'Active'
            ? AppColors.infoBlue
            : record.status == 'Resolved'
                ? AppColors.successGreen
                : AppColors.lightSubText;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.infoBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  record.caseNumber,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.infoBlue),
                ),
              ),
              _statusBadge(record.status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              record.firestoreCategoryDisplayName,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            record.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.lightSubText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person_rounded,
                  size: 14, color: AppColors.lightSubText),
              const SizedBox(width: 4),
              Text(record.assignedOfficer,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.lightSubText)),
              const Spacer(),
              Text(DateFormat('dd MMM yyyy').format(record.incidentDate),
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.lightSubText)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionbtn(
                  context, Icons.edit_note_rounded, 'Edit', AppColors.infoBlue,
                  () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                      page: CaseFormScreen(
                          categoryName: categoryName, existingCase: record)),
                );
              }),
              _actionbtn(context, Icons.picture_as_pdf_rounded, 'PDF',
                  AppColors.dangerRed, () {
                runWithPdfAuthGate(
                  context,
                  () => PdfHelper.generateCasePdf(record),
                );
              }),
              _actionbtn(context, Icons.visibility_rounded, 'View',
                  AppColors.goldPrimary, () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                      page: CaseDetailScreen(caseData: record)),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _actionbtn(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
