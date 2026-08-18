// One-time migration script — run: dart run tools/migrate_bilingual_fields.dart
import 'dart:io';

final files = [
  'lib/widgets/crime_detail_form_view.dart',
  'lib/widgets/property_seizure_form_view.dart',
  'lib/widgets/crimespot_seizure_form_view.dart',
  'lib/widgets/arrest_surrender_form_view.dart',
  'lib/widgets/inquest_panchanama_form_view.dart',
];

final replacements = [
  ['_buildSimpleUnderlineInput(', 'BilingualSimpleUnderlineInput('],
  ['_buildDynamicLinedTextField(', 'BilingualDynamicLinedTextField('],
  ['_buildNumberedMethodField(', 'BilingualNumberedMethodField('],
  ['_buildMultilineField(', 'BilingualMultilineField('],
  ['_buildSectionHeader(', 'BilingualSectionHeader('],
  ['_buildInlineField(', 'BilingualField('],
  ['_buildWideField(', 'BilingualWideField('],
  ['_buildFieldRow(', 'BilingualFieldRow('],
];

// Patterns to remove duplicated private helper method definitions.
final removePatterns = [
  RegExp(
    r'\n  Widget _buildSimpleUnderlineInput\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildInlineField\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildWideField\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildDynamicLinedTextField\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildMultilineField\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildSectionHeader\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildFieldRow\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  Widget _buildNumberedMethodField\(\{[\s\S]*?\n  \}\n',
    multiLine: true,
  ),
  RegExp(
    r'\n  // ── Crime Detail field helpers[\s\S]*?\n  Widget _buildCheckbox',
    multiLine: true,
  ),
  RegExp(
    r'\n  // --- HELPER WIDGETS ---\n',
    multiLine: true,
  ),
];

void main() {
  var totalBefore = 0;
  var totalAfter = 0;

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    final before = content.split('\n').length;
    totalBefore += before;

    if (!content.contains("import 'bilingual_field.dart';")) {
      content = content.replaceFirst(
        RegExp(r"import 'responsive_field_row\.dart';"),
        "import 'responsive_field_row.dart';\nimport 'bilingual_field.dart';",
      );
      if (!content.contains("import 'bilingual_field.dart';")) {
        // crimespot may not have responsive_field_row on same line pattern
        content = content.replaceFirst(
          RegExp(r"import 'a4_zoomable_view\.dart';"),
          "import 'a4_zoomable_view.dart';\nimport 'bilingual_field.dart';",
        );
      }
      if (!content.contains("import 'bilingual_field.dart';")) {
        content = content.replaceFirst(
          "import 'package:google_fonts/google_fonts.dart';",
          "import 'package:google_fonts/google_fonts.dart';\nimport 'bilingual_field.dart';",
        );
      }
    }

    for (final pair in replacements) {
      content = content.replaceAll(pair[0], pair[1]);
    }

    for (final pattern in removePatterns) {
      content = content.replaceAll(pattern, '\n');
    }

    // Fix arrest file: restore _buildCheckbox after accidental removal
    content = content.replaceAll(
      '\n\n  Widget _buildCheckbox',
      '\n  Widget _buildCheckbox',
    );

    file.writeAsStringSync(content);
    final after = content.split('\n').length;
    totalAfter += after;
    stdout.writeln('$path: $before -> $after lines (${before - after} removed)');
  }

  stdout.writeln('Total: $totalBefore -> $totalAfter (${totalBefore - totalAfter} lines removed)');
}
