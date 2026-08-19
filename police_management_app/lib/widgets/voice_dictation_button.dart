import 'package:flutter/material.dart';
import '../utils/voice_speech.dart';

/// A sleek, dedicated voice-to-text dictation button for police forms.
/// Supports Marathi (मराठी), Hindi (हिंदी), and English with live streaming transcription.
class VoiceDictationButton extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool appendMode;
  final VoidCallback? onSpeechCompleted;

  const VoiceDictationButton({
    super.key,
    required this.controller,
    this.label = 'Dictate / बोला',
    this.appendMode = true,
    this.onSpeechCompleted,
  });

  @override
  State<VoiceDictationButton> createState() => _VoiceDictationButtonState();
}

class _VoiceDictationButtonState extends State<VoiceDictationButton>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _selectedLang = 'mr-IN'; // Default to Marathi for Maharashtra Police
  String _statusMessage = '';
  String _preSpeechText = '';
  late AnimationController _pulseAnim;

  final Map<String, String> _languages = {
    'mr-IN': 'मराठी (Marathi)',
    'hi-IN': 'हिंदी (Hindi)',
    'en-IN': 'English (India)',
  };

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    if (_isListening) {
      stopWebVoiceRecognition();
    }
    _pulseAnim.dispose();
    super.dispose();
  }

  void _toggleDictation() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _statusMessage = 'Listening in ${_languages[_selectedLang]}...';
      _preSpeechText = widget.controller.text;
    });

    startWebVoiceRecognition(
      (text, isFinal) {
        if (!mounted) return;
        setState(() {
          if (widget.appendMode && _preSpeechText.isNotEmpty) {
            final prefix = _preSpeechText.endsWith(' ') || _preSpeechText.endsWith('\n')
                ? _preSpeechText
                : '$_preSpeechText ';
            widget.controller.text = '$prefix$text';
          } else {
            widget.controller.text = text;
          }
          // Move cursor to end
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );

          if (isFinal) {
            _statusMessage = 'Dictated successfully!';
            widget.onSpeechCompleted?.call();
          }
        });
      },
      (status, message) {
        if (!mounted) return;
        if (status == 'listening') {
          setState(() {
            _isListening = true;
            _statusMessage = '🎙️ Listening... Speak now';
          });
        } else if (status == 'ended' || status == 'error') {
          setState(() {
            _isListening = false;
            _statusMessage = message.isNotEmpty ? message : 'Dictation ended';
          });
        }
      },
      lang: _selectedLang,
    );
  }

  void _stopListening() {
    stopWebVoiceRecognition();
    setState(() {
      _isListening = false;
      _statusMessage = 'Dictation stopped';
    });
    widget.onSpeechCompleted?.call();
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Dictation Language / भाषा निवडा',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._languages.entries.map((entry) {
                  final isSelected = _selectedLang == entry.key;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey,
                    ),
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLang = entry.key;
                      });
                      Navigator.pop(ctx);
                      if (_isListening) {
                        _stopListening();
                        _startListening();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final glowColor = _isListening
            ? Colors.redAccent.withValues(alpha: 0.3 + (_pulseAnim.value * 0.4))
            : Colors.transparent;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dictate Button
            InkWell(
              onTap: _toggleDictation,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red.shade50
                      : const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isListening ? Colors.redAccent : const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                    width: _isListening ? 1.5 : 1.0,
                  ),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 16,
                      color: _isListening ? Colors.redAccent : const Color(0xFF1E3A8A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isListening ? 'Listening...' : widget.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isListening ? Colors.redAccent : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Quick Lang Tag
            InkWell(
              onTap: _showLanguagePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLang.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
