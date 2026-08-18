// lib/utils/universal_search.dart
// App-wide search engine — queries all 12 module providers simultaneously.
// Supports text search AND date search with flexible date matching.

import 'package:intl/intl.dart';
import '../modules/core/models/base_record.dart';

// ── Filter Model ──────────────────────────────────────────────────────────────

class SearchFilters {
  bool byTitle;
  bool byFirNumber;
  bool byDate;
  bool byOfficer;
  bool byLocation;
  bool byComplainant;
  bool byAccused;

  SearchFilters({
    this.byTitle = true,
    this.byFirNumber = true,
    this.byDate = true,
    this.byOfficer = true,
    this.byLocation = true,
    this.byComplainant = true,
    this.byAccused = true,
  });

  SearchFilters copyWith({
    bool? byTitle, bool? byFirNumber, bool? byDate, bool? byOfficer,
    bool? byLocation,
    bool? byComplainant, bool? byAccused,
  }) {
    return SearchFilters(
      byTitle: byTitle ?? this.byTitle,
      byFirNumber: byFirNumber ?? this.byFirNumber,
      byDate: byDate ?? this.byDate,
      byOfficer: byOfficer ?? this.byOfficer,
      byLocation: byLocation ?? this.byLocation,
      byComplainant: byComplainant ?? this.byComplainant,
      byAccused: byAccused ?? this.byAccused,
    );
  }

  bool get hasAnyActive =>
      byTitle || byFirNumber || byDate || byOfficer ||
      byLocation || byComplainant || byAccused;

  int get activeCount => [
    byTitle, byFirNumber, byDate, byOfficer,
    byLocation, byComplainant, byAccused,
  ].where((b) => b).length;
}

// ── Result Model ──────────────────────────────────────────────────────────────

class SearchResult {
  final String moduleLabel;
  final String moduleKey;
  final ModuleRecord record;

  const SearchResult({
    required this.moduleLabel,
    required this.moduleKey,
    required this.record,
  });
}

// ── Search Engine ─────────────────────────────────────────────────────────────
class UniversalSearch {
  static final List<DateFormat> _queryParsers = [
    DateFormat('dd MMM yyyy'),
    DateFormat('d MMM yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('d/M/yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('MMM yyyy'),
    DateFormat('MMMM yyyy'),
  ];

  static final List<DateFormat> _dateVariantFormats = [
    DateFormat('dd MMM yyyy'),
    DateFormat('d MMM yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('MMM yyyy'),
    DateFormat('MMMM yyyy'),
    DateFormat('dd MMMM yyyy'),
    DateFormat('yyyy'),
  ];

  /// Parses natural spoken or typed date phrases like "15 August 2026", "15th Aug", "today", "yesterday", etc.
  static DateTime? tryParseNaturalDate(String raw) {
    var text = raw.trim().toLowerCase();
    if (text.isEmpty) return null;

    final now = DateTime.now();
    if (text == 'today') return DateTime(now.year, now.month, now.day);
    if (text == 'yesterday') {
      final y = now.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day);
    }
    if (text == 'tomorrow') {
      final t = now.add(const Duration(days: 1));
      return DateTime(t.year, t.month, t.day);
    }

    // Clean ordinal suffixes: "15th" -> "15", "1st" -> "1", "2nd" -> "2", "3rd" -> "3"
    text = text.replaceAll(RegExp(r'(\d+)(st|nd|rd|th)\b'), r'$1');

    // Standard formats
    final parsers = [
      DateFormat('d MMMM yyyy'),
      DateFormat('dd MMMM yyyy'),
      DateFormat('d MMM yyyy'),
      DateFormat('dd MMM yyyy'),
      DateFormat('MMMM d yyyy'),
      DateFormat('MMM d yyyy'),
      DateFormat('MMMM d, yyyy'),
      DateFormat('MMM d, yyyy'),
      DateFormat('d MMMM'),
      DateFormat('dd MMMM'),
      DateFormat('d MMM'),
      DateFormat('dd MMM'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('d/M/yyyy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('d-M-yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('yyyy/MM/dd'),
      DateFormat('dd.MM.yyyy'),
    ];

    for (final p in parsers) {
      try {
        final d = p.parseStrict(text);
        if (d.year == 1970) {
          return DateTime(now.year, d.month, d.day);
        }
        return DateTime(d.year, d.month, d.day);
      } catch (_) {}
    }

    // Match patterns inside phrases like "15 august 2026" or "15 aug"
    final dateRegex = RegExp(
      r'\b(\d{1,2})\s+(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)\s*(\d{4})?\b',
      caseSensitive: false,
    );
    final match = dateRegex.firstMatch(text);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '1') ?? 1;
      final monthStr = match.group(2)!.toLowerCase();
      final year = int.tryParse(match.group(3) ?? '${now.year}') ?? now.year;

      const months = {
        'january': 1, 'jan': 1,
        'february': 2, 'feb': 2,
        'march': 3, 'mar': 3,
        'april': 4, 'apr': 4,
        'may': 5,
        'june': 6, 'jun': 6,
        'july': 7, 'jul': 7,
        'august': 8, 'aug': 8,
        'september': 9, 'sep': 9, 'sept': 9,
        'october': 10, 'oct': 10,
        'november': 11, 'nov': 11,
        'december': 12, 'dec': 12,
      };
      final month = months[monthStr] ?? 1;
      return DateTime(year, month, day);
    }

    return null;
  }

  /// Returns all matching records across ALL modules.
  static List<SearchResult> search({
    required String query,
    required List<(String label, String key, List<ModuleRecord> records)> moduleSources,
    required SearchFilters filters,
    DateTime? exactDate,
  }) {
    if (query.isEmpty && exactDate == null) return [];

    final rawQ = query.trim().toLowerCase();
    // Build query tokens and normalized variations (e.g. "fir 102" -> ["102", "fir 102"])
    final queryVariations = _extractQueryVariations(rawQ);
    final results = <SearchResult>[];
    final dateVariants = _buildDateVariants(query.trim());

    for (final source in moduleSources) {
      final (_, key, records) = source;
      for (final record in records) {
        if (_matches(record, queryVariations, dateVariants, filters, exactDate)) {
          results.add(SearchResult(
            moduleLabel: record.firestoreCategoryDisplayName,
            moduleKey: key,
            record: record,
          ));
        }
      }
    }

    results.sort((a, b) => b.record.createdAt.compareTo(a.record.createdAt));
    return results;
  }

  static List<String> _extractQueryVariations(String raw) {
    final list = <String>{raw};
    
    // Strip common speech prefixes: "fir 45" -> "45", "fir number 102" -> "102"
    var stripped = raw;
    final prefixPatterns = [
      RegExp(r'^(search\s+for\s+|search\s+|find\s+|show\s+|show\s+me\s+|give\s+me\s+)', caseSensitive: false),
      RegExp(r'^(fir\s+number\s+|fir\s+no\s*[:\.\-]?\s*|fir\s+|cr\s+no\s*[:\.\-]?\s*|cr\s+|case\s+no\s*[:\.\-]?\s*|case\s+number\s+|case\s+)', caseSensitive: false),
      RegExp(r'^(complainant\s+|accused\s+|officer\s+|location\s+|spot\s+|crime\s+spot\s+)', caseSensitive: false),
    ];

    for (final pat in prefixPatterns) {
      if (pat.hasMatch(stripped)) {
        stripped = stripped.replaceFirst(pat, '').trim();
        if (stripped.isNotEmpty) list.add(stripped);
      }
    }

    return list.toList();
  }

  static bool _matches(
    ModuleRecord r,
    List<String> queryVariations,
    List<String> dateVariants,
    SearchFilters f,
    DateTime? exactDate,
  ) {
    if (exactDate != null) {
      final rd = r.incidentDate;
      final cd = r.createdAt;
      final matchInc = (rd.year == exactDate.year && rd.month == exactDate.month && rd.day == exactDate.day);
      final matchCreated = (cd.year == exactDate.year && cd.month == exactDate.month && cd.day == exactDate.day);
      if (!matchInc && !matchCreated) {
        return false;
      }
      if (queryVariations.isEmpty || queryVariations.first.isEmpty) return true;
    }

    // Check each query variation against the enabled filter fields
    for (final q in queryVariations) {
      if (q.isEmpty) continue;

      if (f.byFirNumber && r.caseNumber.toLowerCase().contains(q)) return true;
      if (f.byTitle && (r.title.toLowerCase().contains(q) || (r.subCategory?.toLowerCase().contains(q) ?? false))) return true;
      if (f.byOfficer && r.assignedOfficer.toLowerCase().contains(q)) return true;
      if (f.byLocation && r.location.toLowerCase().contains(q)) return true;
      if (f.byComplainant && r.complainant.toLowerCase().contains(q)) return true;
      if (f.byAccused && r.accused.toLowerCase().contains(q)) return true;

      // Description & extraFields search
      if (r.description.toLowerCase().contains(q)) return true;
      for (final val in r.extraFields.values) {
        if (val != null && val.toString().toLowerCase().contains(q)) return true;
      }

      // Check multi-word tokens (e.g. "Ramesh Theft" matches if title has Theft and complainant has Ramesh)
      final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.length > 1) {
        final combinedText = '${r.title} ${r.caseNumber} ${r.subCategory ?? ''} ${r.complainant} ${r.accused} ${r.location} ${r.assignedOfficer} ${r.description} ${r.extraFields.values.join(' ')}'.toLowerCase();
        if (words.every((w) => combinedText.contains(w))) return true;
      }
    }

    if (f.byDate) {
      for (final variant in dateVariants) {
        if (_dateMatchesRecord(r.incidentDate, variant) || _dateMatchesRecord(r.createdAt, variant)) {
          return true;
        }
      }
    }

    return false;
  }

  static List<String> _buildDateVariants(String raw) {
    final variants = <String>[raw.toLowerCase()];
    DateTime? parsed;
    for (final p in _queryParsers) {
      try {
        parsed = p.parseStrict(raw);
        break;
      } catch (_) {}
    }

    if (parsed != null) {
      variants.addAll([
        DateFormat('dd MMM yyyy').format(parsed).toLowerCase(),
        DateFormat('d MMM yyyy').format(parsed).toLowerCase(),
        DateFormat('dd/MM/yyyy').format(parsed).toLowerCase(),
        DateFormat('yyyy-MM-dd').format(parsed).toLowerCase(),
        DateFormat('MMM yyyy').format(parsed).toLowerCase(),
        DateFormat('dd MMMM yyyy').format(parsed).toLowerCase(),
        parsed.year.toString(),
      ]);
    }
    return variants;
  }

  static bool _dateMatchesRecord(DateTime date, String variant) {
    for (final f in _dateVariantFormats) {
      if (f.format(date).toLowerCase().contains(variant)) return true;
    }
    return false;
  }

  /// Groups flat results by [SearchResult.moduleKey] (Firestore module id).
  static Map<String, List<SearchResult>> groupByModule(List<SearchResult> results) {
    final grouped = <String, List<SearchResult>>{};
    for (final r in results) {
      grouped.putIfAbsent(r.moduleKey, () => []).add(r);
    }
    return grouped;
  }
}
