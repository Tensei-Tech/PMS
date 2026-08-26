import 'package:flutter/foundation.dart';

/// Global high-precision performance measurement tool for empirical timing.
class PerfTracker {
  /// Set to true if you want to inspect performance metrics in the terminal console.
  static bool enableLogging = false;
  static final Stopwatch _appStopwatch = Stopwatch()..start();
  static final Map<String, Stopwatch> _operationStopwatches = {};

  static void log(String milestone) {
    if (!enableLogging) return;
    final elapsed = _appStopwatch.elapsedMilliseconds;
    debugPrint('[PERF_METRICS] [T+${elapsed}ms] $milestone');
  }

  static void startOp(String label) {
    if (!enableLogging) return;
    final sw = Stopwatch()..start();
    _operationStopwatches[label] = sw;
    final elapsed = _appStopwatch.elapsedMilliseconds;
    debugPrint('[PERF_METRICS] [T+${elapsed}ms] ▶️ START: $label');
  }

  static int stopOp(String label) {
    if (!enableLogging) return -1;
    final sw = _operationStopwatches.remove(label);
    if (sw == null) return -1;
    final duration = sw.elapsedMilliseconds;
    final elapsed = _appStopwatch.elapsedMilliseconds;
    debugPrint('[PERF_METRICS] [T+${elapsed}ms] ⏹️ END: $label (Duration: ${duration}ms)');
    return duration;
  }

  static void reset(String label) {
    if (!enableLogging) return;
    _appStopwatch.reset();
    _appStopwatch.start();
    debugPrint('[PERF_METRICS] ⏱️ Stopwatch reset: $label');
  }
}

