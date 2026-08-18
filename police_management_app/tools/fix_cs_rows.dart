import 'dart:io';

void main() {
  var c = File(r'lib\widgets\inquest_panchanama_form_view.dart').readAsStringSync();
  c = c.replaceAllMapped(
    RegExp(r'(_buildCSRow\([^)]+\)),\s*maxLines:\s*(\d+)\)'),
    (m) => '${m.group(1)}, maxLines: ${m.group(2)}, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)',
  );
  c = c.replaceAllMapped(
    RegExp(r'_buildCSRow\(([^,]+,\s*_cs\w+Ctrl)\)(?!,)'),
    (m) => '_buildCSRow(${m.group(1)}, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)',
  );
  File(r'lib\widgets\inquest_panchanama_form_view.dart').writeAsStringSync(c);
}
