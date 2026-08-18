import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/voice_speech.dart';

/// Interactive Voice Search Dialog with Live Keyboard Editing & Spell Correction.
class VoiceSearchDialog extends StatefulWidget {
  const VoiceSearchDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const VoiceSearchDialog(),
    );
  }

  @override
  State<VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<VoiceSearchDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final TextEditingController _voiceInputCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isListening = true;
  String _statusMessage = 'Listening… Speak into your microphone now!';

  Timer? _autoSubmitTimer;
  bool _userIsEditing = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _userIsEditing = true;
        _autoSubmitTimer?.cancel();
      }
    });

    _voiceInputCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  @override
  void dispose() {
    _autoSubmitTimer?.cancel();
    _pulseCtrl.dispose();
    _voiceInputCtrl.dispose();
    _focusNode.dispose();
    _stopListening();
    super.dispose();
  }

  void _startListening() {
    _autoSubmitTimer?.cancel();
    _userIsEditing = false;
    setState(() {
      _isListening = true;
      _statusMessage = 'Listening… Speak into your microphone now!';
    });
    if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);

    startWebVoiceRecognition(
      (text, isFinal) {
        if (!mounted) return;
        setState(() {
          _voiceInputCtrl.text = text;
          _voiceInputCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
          _statusMessage = 'Recognized: "$text"';
        });

        // If speech recognition marks this phrase as final, directly search!
        if (isFinal && text.trim().isNotEmpty && !_userIsEditing) {
          _scheduleDirectSearch(text);
        }
      },
      (status, message) {
        if (!mounted) return;
        setState(() {
          if (status == 'listening') {
            _isListening = true;
            _statusMessage = 'Listening… Speak into your mic now!';
          } else if (status == 'error' || status == 'unsupported') {
            _isListening = false;
            _statusMessage = message;
            _pulseCtrl.stop();
          } else if (status == 'ended') {
            _isListening = false;
            _pulseCtrl.stop();

            final currentText = _voiceInputCtrl.text.trim();
            if (currentText.isNotEmpty && !_userIsEditing) {
              _statusMessage = 'Searching for "$currentText"…';
              _scheduleDirectSearch(currentText);
            } else if (currentText.isEmpty) {
              _statusMessage = 'Tap mic to speak or type with keyboard below';
            }
          }
        });
      },
    );
  }

  void _scheduleDirectSearch(String text) {
    _autoSubmitTimer?.cancel();
    _autoSubmitTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && !_userIsEditing) {
        _submitSpeech(text);
      }
    });
  }

  void _stopListening() {
    _autoSubmitTimer?.cancel();
    stopWebVoiceRecognition();
    setState(() {
      _isListening = false;
    });
    _pulseCtrl.stop();
  }

  void _submitSpeech(String text) {
    _autoSubmitTimer?.cancel();
    final cleaned = text.trim();
    if (cleaned.isNotEmpty) {
      _stopListening();
      if (mounted) Navigator.of(context).pop(cleaned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _voiceInputCtrl.text.trim().isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header Row ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: AppColors.goldDark,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Voice & Speak Search',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.lightSubText,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Pulsing Mic Animation ─────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? const Color(0xFF0072FF).withValues(alpha: 0.16)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isListening
                                ? [const Color(0xFF0072FF), const Color(0xFF00C6FF)]
                                : [Colors.grey.shade400, Colors.grey.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? const Color(0xFF0072FF) : Colors.grey)
                                  .withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Status Message ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _isListening ? AppColors.navyMid : AppColors.lightSubText,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Live Editable Input Box (Keyboard & Spell Correction) ─────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightBg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: hasText ? AppColors.navyMid : AppColors.lightBorder,
                      width: 1.3,
                    ),
                  ),
                  child: TextField(
                    controller: _voiceInputCtrl,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.text,
                    enableSuggestions: true,
                    autocorrect: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) => _submitSpeech(val),
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Speak or edit with keyboard here...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSubText,
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: AppColors.navyMid,
                      ),
                      suffixIcon: hasText
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              color: AppColors.lightSubText,
                              onPressed: () {
                                _voiceInputCtrl.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Edit Hint ─────────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(
                      Icons.keyboard_rounded,
                      size: 13,
                      color: AppColors.lightSubText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Spelling wrong? Click inside the box to edit anytime.',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppColors.lightSubText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Action Buttons Row ────────────────────────────────────────
                Row(
                  children: [
                    // Re-speak button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 16,
                          color: AppColors.navyMid,
                        ),
                        label: Text(
                          _isListening ? 'Stop' : 'Re-speak',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyMid,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.lightBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () {
                          if (_isListening) {
                            _stopListening();
                          } else {
                            _startListening();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Search / Submit button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.search_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Search Now',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          elevation: 2,
                        ),
                        onPressed: hasText
                            ? () => _submitSpeech(_voiceInputCtrl.text)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
