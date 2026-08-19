// Stub implementation of web speech recognition for non-web platforms

void startWebVoiceRecognition(
  void Function(String text, bool isFinal) onResult,
  void Function(String status, String message) onStatus, {
  String lang = 'en-IN',
}) {}

void stopWebVoiceRecognition() {}
