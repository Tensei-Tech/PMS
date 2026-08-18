import re

with open('lib/widgets/form_e_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _buildField definition
old_build_field = '''  Widget _buildField({
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
            Text('\ \', style: englishStyle),
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
  }'''

new_build_field = '''  TableRow _buildTableRow({
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
  }'''

content = content.replace(old_build_field, new_build_field)

# Replace Column with Table
old_column_start = '''                    // --- FIELDS ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ['''

new_table_start = '''                    // --- FIELDS ---
                    Table(
                      border: TableBorder.all(color: Colors.black87, width: 1.0),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(3),
                      },
                      children: ['''

content = content.replace(old_column_start, new_table_start)

# Replace _buildField calls
content = content.replace('_buildField(srNo:', '_buildTableRow(srNo:')

with open('lib/widgets/form_e_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
