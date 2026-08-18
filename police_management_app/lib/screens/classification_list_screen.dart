// lib/screens/classification_list_screen.dart
// Issue 6: Generic screen for each classification type from the drawer.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ClassificationListScreen extends StatefulWidget {
  final String classificationType;

  const ClassificationListScreen({
    super.key,
    required this.classificationType,
  });

  @override
  State<ClassificationListScreen> createState() =>
      _ClassificationListScreenState();
}

class _ClassificationListScreenState extends State<ClassificationListScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Open', 'Active', 'Resolved'];

  // Mock data — in production, this would be fetched from backend
  // filtered by widget.classificationType
  late List<Map<String, dynamic>> _cases;

  @override
  void initState() {
    super.initState();
    _cases = _generateMockCases();
  }

  List<Map<String, dynamic>> _generateMockCases() {
    // Generate relevant mock cases based on classification type
    final type = widget.classificationType;
    final statuses = ['Open', 'Active', 'Resolved', 'Open', 'Active'];
    final statusColors = [
      AppColors.warningOrange,
      AppColors.infoBlue,
      AppColors.successGreen,
      AppColors.warningOrange,
      AppColors.infoBlue,
    ];

    return List.generate(5, (i) {
      return {
        'title': '$type Case — Record #00${i + 1}',
        'id': 'CLS/${DateTime.now().year}/0${i + 1}',
        'type': type,
        'date': '${(8 - i)} Apr ${DateTime.now().year}',
        'status': statuses[i],
        'statusColor': statusColors[i],
        'officer': 'SI Officer ${i + 1}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? _cases
        : _cases.where((c) => c['status'] == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.classificationType,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark)),
            Text('${filtered.length} records found',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.lightSubText)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: AppColors.navyDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded,
                color: AppColors.navyMid),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Classification type banner
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navyMid, AppColors.navyMid.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                    color: AppColors.navyMid.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.folder_special_rounded,
                      color: AppColors.goldPrimary, size: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.classificationType,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text('Classification Records',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text('${_cases.length}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDark)),
                ),
              ],
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: _filters.map((f) {
                final isActive = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (AppColors.navyMid)
                          : (Colors.white),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color: isActive
                              ? (AppColors.navyMid)
                              : (AppColors.lightBorder)),
                    ),
                    child: Text(f,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? (Colors.white)
                                : (AppColors.lightText))),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Case list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded,
                            size: 64,
                            color: AppColors.lightSubText),
                        const SizedBox(height: AppSpacing.md),
                        Text('No records found',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightSubText)),
                        Text('Try a different filter',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.lightSubText)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final c = filtered[i];
                      final statusColor = c['statusColor'] as Color;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                              color: AppColors.lightBorder),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 
                                    0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.navyMid.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(Icons.folder_rounded,
                                color: AppColors.navyMid,
                                size: 22),
                          ),
                          title: Text(
                            c['title'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${c['id']} · ${c['date']} · ${c['officer']}',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.lightSubText),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm)),
                            child: Text(c['status'] as String,
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor)),
                          ),
                          onTap: () {
                            // Navigate to case detail in production
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // FAB to add new record
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open add record form in production
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Add ${widget.classificationType} record',
                  style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: AppColors.navyMid,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          );
        },
        backgroundColor:
            AppColors.navyMid,
        foregroundColor:
            Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Record',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }
}