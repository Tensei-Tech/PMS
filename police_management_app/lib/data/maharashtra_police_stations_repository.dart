// lib/data/maharashtra_police_stations_repository.dart
// Parses Maharashtra police stations CSV and provides structured data.

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

/// Represents a police station entry from the CSV.
class PoliceStation {
  final String districtName;
  final String stationName;
  final String type; // 'Commissionerate' or 'Superintendent'

  const PoliceStation({
    required this.districtName,
    required this.stationName,
    required this.type,
  });

  /// Returns the display name for the station.
  String get displayName => stationName;

  @override
  String toString() => 'PoliceStation(district: $districtName, station: $stationName, type: $type)';
}

/// Repository for Maharashtra police stations loaded from CSV.
/// 
/// Provides:
/// - List of all districts/commissionerates
/// - Map of District -> List of Stations
/// - Filter stations by unit type (Commissionerate vs Superintendent)
class MaharashtraPoliceStationsRepository {
  static List<PoliceStation>? _cachedStations;
  static Map<String, List<PoliceStation>>? _cachedByDistrict;
  static List<String>? _cachedDistricts;

  /// Load and parse the CSV file.
  static Future<void> initialize() async {
    if (_cachedStations != null) return; // Already loaded

    try {
      final csvString = await rootBundle.loadString('assets/data/maharashtra_police_stations.csv');
      final rows = const CsvToListConverter().convert(csvString);
      
      // Skip header row and parse
      final stations = <PoliceStation>[];
      final byDistrict = <String, List<PoliceStation>>{};
      
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 3) continue; // Skip invalid rows
        
        final district = row[0]?.toString().trim() ?? '';
        final station = row[1]?.toString().trim() ?? '';
        final type = row[2]?.toString().trim() ?? '';
        
        if (district.isEmpty || station.isEmpty) continue;
        
        // Normalize type to match the repository constants
        final normalizedType = type.toLowerCase().contains('commissionerate') 
            ? 'Commissionerate Police' 
            : 'Superintendent of Police';
        
        final policeStation = PoliceStation(
          districtName: district,
          stationName: station,
          type: normalizedType,
        );
        
        stations.add(policeStation);
        byDistrict.putIfAbsent(district, () => []).add(policeStation);
      }
      
      _cachedStations = stations;
      _cachedByDistrict = byDistrict;
      _cachedDistricts = byDistrict.keys.toList()..sort();
    } catch (e) {
      // If CSV fails to load, initialize with empty data
      _cachedStations = [];
      _cachedByDistrict = {};
      _cachedDistricts = [];
      rethrow;
    }
  }

  /// Returns all districts/commissionerates sorted alphabetically.
  static List<String> getDistricts() {
    _ensureLoaded();
    return _cachedDistricts ?? [];
  }

  /// Returns all police stations for a given district.
  static List<PoliceStation> getStationsForDistrict(String district) {
    _ensureLoaded();
    return _cachedByDistrict?[district] ?? [];
  }

  /// Returns station names for a district filtered by unit type.
  static List<String> getStationNamesForSelection({
    required String district,
    required String unitType, // 'Commissionerate Police' or 'Superintendent of Police'
  }) {
    _ensureLoaded();
    final stations = _cachedByDistrict?[district] ?? [];
    return stations
        .where((s) => s.type == unitType)
        .map((s) => s.stationName)
        .toList();
  }

  /// Returns the complete map of District -> List of Stations.
  static Map<String, List<PoliceStation>> getAllStationsByDistrict() {
    _ensureLoaded();
    return _cachedByDistrict ?? {};
  }

  /// Returns all stations (useful for search functionality).
  static List<PoliceStation> getAllStations() {
    _ensureLoaded();
    return _cachedStations ?? [];
  }

  /// Search stations by name across all districts.
  static List<PoliceStation> searchStations(String query) {
    _ensureLoaded();
    if (query.isEmpty) return _cachedStations ?? [];
    
    final q = query.toLowerCase();
    return (_cachedStations ?? []).where((s) {
      return s.stationName.toLowerCase().contains(q) ||
             s.districtName.toLowerCase().contains(q);
    }).toList();
  }

  /// Check if data is loaded.
  static bool get isLoaded => _cachedStations != null;

  /// Clear cache (useful for testing or memory management).
  static void clearCache() {
    _cachedStations = null;
    _cachedByDistrict = null;
    _cachedDistricts = null;
  }

  static void _ensureLoaded() {
    if (_cachedStations == null) {
      throw StateError(
        'MaharashtraPoliceStationsRepository not initialized. '
        'Call initialize() before using the repository.'
      );
    }
  }
}
