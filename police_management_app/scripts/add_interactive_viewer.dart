import 'dart:io';

void main() {
  final files = [
    'lib/widgets/form_e_view.dart',
    'lib/widgets/crimespot_seizure_form_view.dart',
    'lib/widgets/property_seizure_form_view.dart',
    'lib/widgets/crime_detail_form_view.dart'
  ];

  const targetStart = '''        child: Center(
          child: FittedBox(''';

  const replacementStart = '''        child: Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: FittedBox(''';

  const targetEnd = '''              ),
            ),
          ),
        ),
      ),
    );
  }''';

  const replacementEnd = '''                ),
              ),
            ),
          ),
        ),
      ),
    );
  }''';

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      stdout.writeln('File not found: $filePath');
      continue;
    }
    
    var content = file.readAsStringSync();
    if (content.contains(targetStart) && content.contains(targetEnd)) {
      content = content.replaceFirst(targetStart, replacementStart);
      content = content.replaceFirst(targetEnd, replacementEnd);
      file.writeAsStringSync(content);
      stdout.writeln('Updated $filePath');
    } else {
      stdout.writeln('Failed to find patterns in $filePath');
    }
  }
}
