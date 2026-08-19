// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:js' as js;

Stream<html.Event>? _resultStream;
Stream<html.Event>? _statusStream;

void startWebVoiceRecognition(
  void Function(String text, bool isFinal) onResult,
  void Function(String status, String message) onStatus, {
  String lang = 'en-IN',
}) {
  try {
    // Setup event listeners if not already setup
    _resultStream ??= html.window.on['voice_result'];
    _resultStream?.listen((event) {
      if (event is html.CustomEvent && event.detail != null) {
        final text = event.detail['text']?.toString() ?? '';
        final isFinal = event.detail['isFinal'] == true;
        onResult(text, isFinal);
      }
    });

    _statusStream ??= html.window.on['voice_status'];
    _statusStream?.listen((event) {
      if (event is html.CustomEvent && event.detail != null) {
        final status = event.detail['status']?.toString() ?? '';
        final message = event.detail['message']?.toString() ?? '';
        onStatus(status, message);
      }
    });

    // Call JavaScript voiceRecognizer.start(lang)
    if (js.context.hasProperty('voiceRecognizer')) {
      final recognizer = js.context['voiceRecognizer'];
      if (recognizer != null) {
        recognizer.callMethod('start', [lang]);
      }
    }
  } catch (e) {
    onStatus('error', 'Error initializing voice: $e');
  }
}

void stopWebVoiceRecognition() {
  try {
    if (js.context.hasProperty('voiceRecognizer')) {
      final recognizer = js.context['voiceRecognizer'];
      if (recognizer != null) {
        recognizer.callMethod('stop', []);
      }
    }
  } catch (_) {}
}
