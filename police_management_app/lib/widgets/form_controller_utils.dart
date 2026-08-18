import 'package:flutter/material.dart';

void disposeControllers(Iterable<TextEditingController> controllers) {
  for (final c in controllers) {
    c.dispose();
  }
}

Map<String, dynamic> collectFromControllers(
  Map<String, TextEditingController> fields,
) {
  return fields.map((key, ctrl) => MapEntry(key, ctrl.text.trim()));
}

void hydrateControllers(
  Map<String, dynamic> data,
  Map<String, TextEditingController> fields,
) {
  for (final entry in fields.entries) {
    entry.value.text = data[entry.key]?.toString() ?? '';
  }
}
