import 'dart:io';

void main() {
  var file = File('lib/widgets/form_e_view.dart');
  var content = file.readAsStringSync();

  var oldBuildField = '''  Widget _buildField({
    required String srNo,
    required String englishLabel,
    required String marathiLabel,
    required TextEditingController controller,
    required TextStyle englishStyle,
    required TextStyle marathiStyle,
    int? minLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveFieldRow(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$srNo', style: englishStyle),
            Expanded(
              child: _buildSimpleUnderlineInput(
                controller: controller,
                serifStyle: englishStyle,
                minLines: minLines,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(marathiLabel, style: marathiStyle),
        const SizedBox(height: 24),
      ],
    );
  }''';

  var newBuildField = '''  TableRow _buildTableRow({
    required String srNo,
    required String englishLabel,
    required String marathiLabel,
    required TextEditingController controller,
    required TextStyle englishStyle,
    required TextStyle marathiStyle,
    int? minLines,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(srNo, style: englishStyle, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (englishLabel.trim().isNotEmpty) Text(englishLabel, style: englishStyle.copyWith(fontWeight: FontWeight.bold)),
              Text(marathiLabel, style: marathiStyle),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            minLines: minLines ?? 1,
            maxLines: minLines != null ? null : 1,
            style: englishStyle,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }''';

  content = content.replaceAll(oldBuildField, newBuildField);

  var oldColumnStart = '''                    // --- FIELDS ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [''';

  var newTableStart = '''                    // --- FIELDS ---
                    Table(
                      border: TableBorder.all(color: Colors.black87, width: 1.0),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(3),
                      },
                      children: [''';

  content = content.replaceAll(oldColumnStart, newTableStart);
  content = content.replaceAll('_buildField(srNo:', '_buildTableRow(srNo:');

  file.writeAsStringSync(content);
  stdout.writeln('Done');
}
