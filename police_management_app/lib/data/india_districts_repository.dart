import 'dart:convert';
import 'package:flutter/services.dart';

/// Loads and serves the complete districts list for Indian states and UTs
/// from a local bundled JSON file.
class IndiaDistrictsRepository {
  IndiaDistrictsRepository._();

  static Map<String, List<String>>? _cache;

  /// Returns a map of `State/UT -> Districts[]`.
  static Future<Map<String, List<String>>> load() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/data/india_districts.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final districts = (decoded['districts'] as List).cast<Map<String, dynamic>>();

    final Map<String, List<String>> map = {};
    for (final d in districts) {
      final state = (d['state'] as String).trim();
      final district = (d['district'] as String).trim();
      map.putIfAbsent(state, () => <String>[]);
      if (!map[state]!.contains(district)) {
        map[state]!.add(district);
      }
    }

    // Sort for better UX.
    for (final e in map.entries) {
      e.value.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }

    _cache = map;
    return map;
  }
}

