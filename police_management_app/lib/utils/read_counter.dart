// lib/utils/read_counter.dart
// Lightweight Firestore read counter for dev-mode read auditing.
// Set [enabled] = true before running to see live read counts in the terminal.
// Set back to false before committing to production.

import 'package:flutter/foundation.dart';

class ReadCounter {
  /// Toggle this to enable/disable live read counting in the terminal.
  static bool enabled = true;

  static int _totalDocs = 0;
  static int _totalQueries = 0;
  static final Stopwatch _sessionClock = Stopwatch();

  /// Call once at app start (e.g. in main()) to start the session timer.
  static void startSession() {
    _totalDocs = 0;
    _totalQueries = 0;
    _sessionClock.reset();
    _sessionClock.start();
    if (enabled) debugPrint('[READ_COUNTER] 🟢 Session started.');
  }

  /// Call this every time a Firestore query/stream returns documents.
  /// [source] is a human-readable label like "watchUser", "getCasesStream" etc.
  /// [docCount] is snapshot.docs.length or 1 for a single document read.
  static void record(String source, int docCount) {
    if (!enabled) return;
    _totalDocs += docCount;
    _totalQueries++;
    final elapsed = _sessionClock.elapsedMilliseconds;
    debugPrint(
        '[READ_COUNTER] 📄 +$docCount docs | source: $source '
        '| total: $_totalDocs docs / $_totalQueries queries '
        '| T+${elapsed}ms');
  }

  /// Print a full summary — call after dashboard is loaded.
  static void printSummary(String event) {
    if (!enabled) return;
    final elapsed = _sessionClock.elapsedMilliseconds;
    debugPrint(
        '[READ_COUNTER] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '[READ_COUNTER] 📊 SUMMARY at "$event"\n'
        '[READ_COUNTER]   Total documents read : $_totalDocs\n'
        '[READ_COUNTER]   Total query/callbacks: $_totalQueries\n'
        '[READ_COUNTER]   Elapsed time         : ${elapsed}ms\n'
        '[READ_COUNTER] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static int get totalDocs => _totalDocs;
  static int get totalQueries => _totalQueries;
}
