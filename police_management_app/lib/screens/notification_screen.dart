// lib/screens/notification_screen.dart
// Full-page notification history — lists all received FCM notifications.

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/police_rbac_helper.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final items = provider.notifications;
    final firestore = FirestoreService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          ),
          title: Text(
            'Notifications & Reminders',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.warningOrange,
            unselectedLabelColor: AppColors.lightSubText,
            indicatorColor: AppColors.warningOrange,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.notifications_active_rounded, size: 18),
                text: 'Case Reminders',
              ),
              Tab(
                icon: Icon(Icons.mark_email_unread_rounded, size: 18),
                text: 'System Alerts',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── TAB 1: Live Case Reminders from Firestore ──────────────────
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: SeniorOfficerRoles.isCpLevel(auth.designation) ||
                      SeniorOfficerRoles.isSpLevel(auth.designation)
                  ? firestore.getAllRemindersStream()
                  : (auth.isSupervisor || auth.isAdmin)
                      ? firestore.getSentRemindersStream(auth.uid)
                      : (auth.stationName.isNotEmpty
                          ? firestore.getStationRemindersStream(auth.stationName)
                          : firestore.getIoRemindersStream(auth.uid)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reminders = snapshot.data ?? [];
                final isSenior = SeniorOfficerRoles.isCpLevel(auth.designation) ||
                    SeniorOfficerRoles.isSpLevel(auth.designation) ||
                    auth.isSupervisor;

                if (reminders.isEmpty) {
                  return _buildEmptyRemindersState(isSenior: isSenior);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: reminders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = reminders[index];
                    return _buildReminderCard(r, isSenior: isSenior);
                  },
                );
              },
            ),

            // ── TAB 2: System / FCM Alerts ────────────────────────────────
            items.isEmpty ? _buildEmptyState() : _buildList(items),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRemindersState({required bool isSenior}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.warningOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSenior ? 'No Directives Issued Yet' : 'No Case Reminders',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSenior
                  ? 'Supervisory reminders (PCR, FSL, Charge Sheet) you issue to Investigating Officers will be tracked here.'
                  : 'Supervisory reminders sent by Senior Officers will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> r, {required bool isSenior}) {
    final reminderType = r['reminderType'] ?? 'Supervisory Reminder';
    final caseNo = r['caseNumber'] ?? r['caseTitle'] ?? 'Case';
    final sentByName = r['sentByName'] ?? 'Senior Officer';
    final sentByRank = r['sentByDesignation'] ?? '';
    final ioName = r['ioName'] ?? 'Assigned IO';
    final stationName = r['stationName'] ?? '';
    final notes = r['notes'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.warningOrange.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  reminderType,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningOrange,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                caseNo,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyMid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isSenior
                ? 'Assigned IO: $ioName ${stationName.isNotEmpty ? '• $stationName' : ''}'
                : 'From: $sentByName ${sentByRank.isNotEmpty ? '($sentByRank)' : ''}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
            ),
          ),
          if (isSenior) ...[
            const SizedBox(height: 2),
            Text(
              'Issued By: $sentByName ${sentByRank.isNotEmpty ? '($sentByRank)' : ''}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
            ),
          ] else if (ioName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Directed To: $ioName',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Directive: $notes',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.navyDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.navyMid.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 48,
              color: AppColors.navyMid.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No System Alerts',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You\'re all caught up! Push notifications will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.lightSubText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<NotificationItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _NotificationCard(item: item);
      },
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTimestamp(item.timestamp);
    final isUnread = !item.isRead;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.goldPrimary.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isUnread
              ? AppColors.goldPrimary.withValues(alpha: 0.2)
              : AppColors.lightBorder.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ────────────────────────────────────────────────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isUnread
                  ? AppColors.goldPrimary.withValues(alpha: 0.12)
                  : AppColors.navyMid.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isUnread
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_rounded,
              color: isUnread ? AppColors.goldPrimary : AppColors.navyMid,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // ── Content ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.navyDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.goldPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (item.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.lightSubText,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.lightSubText.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.lightSubText.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday, ${DateFormat.jm().format(dt)}';
    if (diff.inDays < 7) return DateFormat('EEEE, h:mm a').format(dt);
    return DateFormat('dd MMM yyyy, h:mm a').format(dt);
  }
}
