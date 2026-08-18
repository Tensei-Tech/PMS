import 'dart:io';

void main() {
  final file = File(r'lib\widgets\inquest_panchanama_form_view.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll('_buildBilingualRow([', '_buildFieldRow(fields: [');
  content = content.replaceAll('_buildBilingualRow(\n', '_buildFieldRow(fields: \n');

  // Multiline fields first (longer pattern)
  content = content.replaceAllMapped(
    RegExp(
      r"_buildBilingualField\(\s*'((?:\\'|[^'])*)',\s*'((?:\\'|[^'])*)',\s*(_\w+Ctrl)\s*,\s*maxLines:\s*(\d+)\s*\)",
      dotAll: true,
    ),
    (m) => "_buildMultilineField(label: '${m.group(1)}', marathiLabel: '${m.group(2)}', controller: ${m.group(3)}, minLines: ${m.group(4)}, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)",
  );

  // Multiline spanning multiple lines
  content = content.replaceAllMapped(
    RegExp(
      r"_buildBilingualField\(\s*\n\s*'((?:\\'|[^'])*)',\s*\n\s*'((?:\\'|[^'])*)',\s*\n\s*(_\w+Ctrl),\s*\n\s*maxLines:\s*(\d+),\s*\n\s*\)",
      dotAll: true,
    ),
    (m) => "_buildMultilineField(label: '${m.group(1)}', marathiLabel: '${m.group(2)}', controller: ${m.group(3)}, minLines: ${m.group(4)}, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)",
  );

  // Simple inline fields
  content = content.replaceAllMapped(
    RegExp(r"_buildBilingualField\('((?:\\'|[^'])*)',\s*'((?:\\'|[^'])*)',\s*(_\w+Ctrl)\)"),
    (m) => "_buildInlineField(label: '${m.group(1)}', marathiLabel: '${m.group(2)}', controller: ${m.group(3)}, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)",
  );

  // Section header pairs
  content = content.replaceAllMapped(
    RegExp(
      r"const Text\('((?:\\'|[^'])*)',\s*style:\s*_englishLabelStyle\),\s*\n\s*const Padding\(\s*\n\s*padding:\s*EdgeInsets\.only\([^)]+\),\s*\n\s*child:\s*Text\('((?:\\'|[^'])*)',\s*style:\s*_marathiLabelStyle\),\s*\n\s*\),",
      dotAll: true,
    ),
    (m) => "_buildSectionHeader(label: '${m.group(1)}', marathiLabel: '${m.group(2)}', serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),",
  );

  content = content.replaceAll('_englishLabelStyle', 'serifStyle');
  content = content.replaceAll('_marathiLabelStyle', 'marathiLabelStyle');

  // habitRow -> _buildHabitRow with named params
  content = content.replaceAllMapped(
    RegExp(
      r"_buildHabitRow\(\s*\n\s*'((?:\\'|[^'])*)',\s*\n\s*'((?:\\'|[^'])*)',\s*\n\s*(_\w+),\s*\n\s*\(v\)\s*=>\s*setState\(\(\)\s*=>\s*(_\w+)\s*=\s*v\s*\?\?\s*false\),\s*\n\s*(_\w+Ctrl),\s*\n\s*\)",
      dotAll: true,
    ),
    (m) => "_buildHabitRow(label: '${m.group(1)}', marathiLabel: '${m.group(2)}', checked: ${m.group(3)}, onChanged: (v) => setState(() => ${m.group(4)} = v ?? false), daysController: ${m.group(5)}, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)",
  );

  if (content.contains('_buildBilingualField')) {
    stdout.writeln('WARNING: remaining _buildBilingualField calls');
    for (final line in content.split('\n').where((l) => l.contains('_buildBilingualField'))) {
      stdout.writeln(line.trim());
    }
  }

  file.writeAsStringSync(content);
  stdout.writeln('Conversion complete');
}
