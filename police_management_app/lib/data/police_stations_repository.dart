/// Police stations list repository (local, offline).
///
/// The app supports selecting a station based on:
/// - State
/// - District
/// - Unit type (Commissionerate Police / Superintendent of Police)
///
/// For now this provides a small curated set + a deterministic fallback list
/// so the registration flow always works offline.
class PoliceStationsRepository {
  static const commissionerate = 'Commissionerate Police';
  static const superintendent = 'Superintendent of Police';

  /// Optional curated stations map keyed by:
  /// `"$unitType|$state|$district"`
  static const Map<String, List<String>> _stations = {
    // Example curated entries (extend as needed)
    '$commissionerate|Delhi|New Delhi': [
      'Connaught Place Police Station',
      'Parliament Street Police Station',
      'Chanakyapuri Police Station',
    ],
    '$superintendent|Uttar Pradesh|Lucknow': [
      'Hazratganj Police Station',
      'Gomti Nagar Police Station',
      'Aliganj Police Station',
    ],
    '$commissionerate|Maharashtra|Mumbai Suburban': [
      'Bandra Police Station',
      'Andheri Police Station',
      'Borivali Police Station',
    ],
  };

  /// Returns stations for the selected unit.
  static List<String> forSelection({
    required String unitType,
    required String state,
    required String district,
  }) {
    final key = '$unitType|$state|$district';
    final curated = _stations[key];
    if (curated != null && curated.isNotEmpty) return curated;

    // Deterministic fallback list (offline, no backend).
    final base = district.isNotEmpty ? district : state;
    return List<String>.generate(
      25,
      (i) => '$base Police Station ${i + 1}',
      growable: false,
    );
  }
}

