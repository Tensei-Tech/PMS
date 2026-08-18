// lib/widgets/send_reminder_dialog.dart
// Dialog allowing In-charges, ACPs, and DCPs to send quick supervisory reminders to IOs.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class SendReminderDialog extends StatefulWidget {
  final ModuleRecord record;

  const SendReminderDialog({super.key, required this.record});

  static Future<void> show(BuildContext context, ModuleRecord record) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SendReminderDialog(record: record),
    );
  }

  @override
  State<SendReminderDialog> createState() => _SendReminderDialogState();
}

class _SendReminderDialogState extends State<SendReminderDialog> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _notesCtrl = TextEditingController();
  String _selectedPreset = 'PCR Not Sent';
  bool _isSubmitting = false;

  static const List<String> _presets = [
    'PCR Not Sent',
    'Pending FSL Report',
    'Charge Sheet Due',
    'Accused Arrest Pending',
    'Witness Statement Pending',
    'Medical Report Pending',
    'Urgent Case Review',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReminder() async {
    final auth = context.read<AuthProvider>();
    final ioName = widget.record.assignedOfficer.trim().isNotEmpty
        ? widget.record.assignedOfficer.trim()
        : 'Assigned IO';
    final ioUid = widget.record.assignedOfficerUid?.trim() ?? '';

    setState(() => _isSubmitting = true);

    try {
      final station = widget.record.stationName.trim().isNotEmpty
          ? widget.record.stationName.trim()
          : auth.stationName.trim();

      await _firestore.sendCaseReminder(
        caseId: widget.record.id,
        caseNumber: widget.record.caseNumber,
        caseTitle: widget.record.title,
        stationName: station,
        ioName: ioName,
        ioUid: ioUid,
        sentByUid: auth.uid,
        sentByName: auth.displayName,
        sentByDesignation: auth.designation,
        reminderType: _selectedPreset,
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reminder sent to $ioName successfully!',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text('Failed to send reminder: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ioName = widget.record.assignedOfficer.trim().isNotEmpty
        ? widget.record.assignedOfficer.trim()
        : 'Assigned IO';
    final firLabel = widget.record.caseNumber.trim().isNotEmpty
        ? widget.record.caseNumber.trim()
        : 'Case #${widget.record.id.substring(0, 6)}';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.warningOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Reminder to IO',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        Text(
                          '$firLabel · $ioName',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.lightSubText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.lightSubText,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reminder Type selection
              Text(
                'Select Reminder Type',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((p) {
                  final isSelected = _selectedPreset == p;
                  return InkWell(
                    onTap: () => setState(() => _selectedPreset = p),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.warningOrange
                            : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.warningOrange
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        p,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.navyDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Additional Instructions / Notes
              Text(
                'Supervisory Notes / Directives (Optional)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 6),

              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.navyDark),
                decoration: InputDecoration(
                  hintText:
                      'Enter any specific instruction (e.g., Expedite within 24 hours)...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.lightSubText,
                  ),
                  filled: true,
                  fillColor: AppColors.lightBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.warningOrange,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.lightSubText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _sendReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.send_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Send Reminder',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
