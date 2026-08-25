// lib/widgets/top_feedback_toast.dart
// Professional floating top-right feedback popup / toast notification.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum TopFeedbackType { success, info, warning, error }

class TopFeedbackToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Shows a floating popup on the top right side of the screen.
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    TopFeedbackType type = TopFeedbackType.success,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayState = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopRightToastWidget(
        title: title,
        message: message,
        type: type,
        onDismiss: () {
          _dismissTimer?.cancel();
          if (_currentEntry == entry) {
            _currentEntry?.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (_currentEntry == entry) {
        _currentEntry?.remove();
        _currentEntry = null;
      }
    });
  }
}

class _TopRightToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final TopFeedbackType type;
  final VoidCallback onDismiss;

  const _TopRightToastWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_TopRightToastWidget> createState() => _TopRightToastWidgetState();
}

class _TopRightToastWidgetState extends State<_TopRightToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );

    _animCtrl.forward();
  }

  void _handleDismiss() async {
    await _animCtrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case TopFeedbackType.success:
        return AppColors.successGreen;
      case TopFeedbackType.warning:
        return AppColors.warningOrange;
      case TopFeedbackType.error:
        return AppColors.dangerRed;
      case TopFeedbackType.info:
        return AppColors.cyanPrimary;
    }
  }

  IconData get _iconData {
    switch (widget.type) {
      case TopFeedbackType.success:
        return Icons.check_circle_rounded;
      case TopFeedbackType.warning:
        return Icons.warning_amber_rounded;
      case TopFeedbackType.error:
        return Icons.error_outline_rounded;
      case TopFeedbackType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;

    // Responsive width calculation: max 360, but fits nicely on small screens
    final toastWidth = (screenWidth - 32).clamp(280.0, 360.0);

    return Positioned(
      top: topPadding + 12,
      right: 16,
      width: toastWidth,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F224A), Color(0xFF0B1733)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _accentColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge Icon
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _iconData,
                        color: _accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Message Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFCFD8DC),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Close Button
                    GestureDetector(
                      onTap: _handleDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
