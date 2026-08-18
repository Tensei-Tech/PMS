// lib/screens/notification_screen.dart
// Full-page notification history — lists all received FCM notifications.

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.notifications;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_rounded,
                  color: AppColors.goldPrimary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.navyMid.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyMid,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Copy FCM Token',
            onPressed: () async {
              try {
                // NOTE: Same VAPID key as in fcm_service.dart
                final token = await FirebaseMessaging.instance.getToken(
                  vapidKey: kIsWeb ? 'YOUR_VAPID_KEY_HERE_REPLACE_ME' : null,
                );
                if (!context.mounted) return;
                
                if (token != null) {
                  await Clipboard.setData(ClipboardData(text: token));
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('FCM Token (Copied)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      content: SelectableText(token, style: GoogleFonts.poppins(fontSize: 12)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: GoogleFonts.poppins()))
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Token is null', style: GoogleFonts.poppins(color: Colors.white)), backgroundColor: AppColors.dangerRed),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Error getting token', style: GoogleFonts.poppins(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                      content: SelectableText(e.toString(), style: GoogleFonts.poppins(fontSize: 12)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: GoogleFonts.poppins()))
                      ],
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.copy_rounded, color: AppColors.navyDark),
          ),
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClearAll(context, provider),
              icon: const Icon(Icons.delete_sweep_rounded,
                  size: 18, color: AppColors.dangerRed),
              label: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dangerRed,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: items.isEmpty ? _buildEmptyState() : _buildList(items),
    );
  }

  void _confirmClearAll(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear All Notifications',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.navyDark)),
        content: Text(
            'Are you sure you want to remove all notifications?',
            style: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.lightSubText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSubText)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Clear All',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
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
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You\'re all caught up! New notifications will appear here.',
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
