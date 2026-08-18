// lib/widgets/bell_icon_widget.dart
// Animated bell icon with red badge counter for FCM notifications.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../screens/notification_screen.dart';
import '../theme/app_theme.dart';

class BellIconWidget extends StatefulWidget {
  const BellIconWidget({super.key});

  @override
  State<BellIconWidget> createState() => _BellIconWidgetState();
}

class _BellIconWidgetState extends State<BellIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    final provider = context.read<NotificationProvider>();
    provider.clearBadge();
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(page: const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    // Trigger bounce animation when count increases.
    if (unread > _prevCount && unread > 0) {
      _bounceCtrl.forward(from: 0);
    }
    _prevCount = unread;

    return GestureDetector(
      onTap: _onTap,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Bell button (matches existing _appBarBtn style) ─────────────
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: AppColors.navyDark,
                size: 20,
              ),
            ),

            // ── Badge counter ───────────────────────────────────────────────
            if (unread > 0)
              Positioned(
                right: 0,
                top: 0,
                child: ScaleTransition(
                  scale: _bounceAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dangerRed.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
