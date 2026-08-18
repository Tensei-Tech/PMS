import 'dart:io';

void removeDuplicateBilingualMethods(String path, String resumeMarker) {
  final lines = File(path).readAsLinesSync();
  final out = <String>[];
  var skipping = false;

  for (final line in lines) {
    if (line.startsWith('  Widget Bilingual')) {
      skipping = true;
      continue;
    }
    if (skipping) {
      if (line.startsWith('  Widget $resumeMarker') ||
          line.startsWith('  // Helper methods')) {
        skipping = false;
        out.add(line);
      }
      continue;
    }
    out.add(line);
  }

  File(path).writeAsStringSync('${out.join('\n')}\n');
}

void removeTrailingBilingualBlock(String path) {
  final lines = File(path).readAsLinesSync();
  final out = <String>[];
  for (final line in lines) {
    if (line.startsWith('  Widget Bilingual')) break;
    out.add(line);
  }
  File(path).writeAsStringSync('${out.join('\n')}\n');
}

void main() {
  removeDuplicateBilingualMethods(
    'lib/widgets/inquest_panchanama_form_view.dart',
    '_buildHabitRow',
  );
  removeDuplicateBilingualMethods(
    'lib/widgets/crime_detail_form_view.dart',
    '_buildHeaderCell',
  );
  removeDuplicateBilingualMethods(
    'lib/widgets/property_seizure_form_view.dart',
    '_buildHeaderCell',
  );
  removeTrailingBilingualBlock('lib/widgets/crimespot_seizure_form_view.dart');

  final arrestPath = 'lib/widgets/arrest_surrender_form_view.dart';
  var arrest = File(arrestPath).readAsStringSync();
  arrest = arrest.replaceFirst(
    '(String label, bool value, ValueChanged<bool?> onChanged, TextStyle serifStyle) {',
    '  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged, TextStyle serifStyle) {',
  );
  File(arrestPath).writeAsStringSync(arrest);

  stdout.writeln('Cleanup complete.');
}
