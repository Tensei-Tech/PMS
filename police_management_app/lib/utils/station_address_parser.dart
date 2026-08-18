// lib/utils/station_address_parser.dart
// Parses registration-style stationAddress strings into structured fields.

/// Parsed components from `"District, State • Unit Type"` station addresses.
class ParsedStationAddress {
  const ParsedStationAddress({
    this.state = '',
    this.district = '',
    this.unitType = '',
  });

  final String state;
  final String district;
  final String unitType;

  bool get hasDistrict => district.trim().isNotEmpty;
}

class StationAddressParser {
  StationAddressParser._();

  /// Expected format from registration:
  /// `"<district>, <state> • <policeUnitType>"`
  static ParsedStationAddress parse(String stationAddress) {
    final raw = stationAddress.trim();
    if (raw.isEmpty) {
      return const ParsedStationAddress();
    }

    final bulletParts = raw.split('•');
    final unitType =
        bulletParts.length > 1 ? bulletParts.last.trim() : '';
    final left = bulletParts.first.trim();

    if (left.isEmpty) {
      return ParsedStationAddress(unitType: unitType);
    }

    final commaIndex = left.indexOf(',');
    if (commaIndex == -1) {
      return ParsedStationAddress(district: left, unitType: unitType);
    }

    return ParsedStationAddress(
      district: left.substring(0, commaIndex).trim(),
      state: left.substring(commaIndex + 1).trim(),
      unitType: unitType,
    );
  }
}
