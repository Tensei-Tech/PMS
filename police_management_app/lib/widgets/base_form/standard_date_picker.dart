// lib/widgets/base_form/standard_date_picker.dart

import 'package:flutter/material.dart';

import 'base_form_styles.dart';
import 'standard_text_field.dart';

/// Date-only field: read-only text + calendar picker (dd/MM/yyyy).
class StandardDatePicker extends StatelessWidget {
  const StandardDatePicker({
    super.key,
    required this.label,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.formatter,
  });

  final String label;
  final TextEditingController controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateChanged;
  final String Function(DateTime)? formatter;

  String _format(DateTime d) =>
      formatter?.call(d) ?? BaseFormStyles.formatDateDdMmYyyy(d);

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final min = firstDate ?? DateTime(2000);
    final max = lastDate ?? now;
    final parsed = BaseFormStyles.parseDateDdMmYyyy(controller.text);
    final initial = parsed != null &&
            !parsed.isBefore(min) &&
            !parsed.isAfter(max)
        ? parsed
        : (max.isBefore(now) ? max : now);

    final picked = await showDatePicker(
      context: context,
      firstDate: min,
      lastDate: max,
      initialDate: initial.isBefore(min)
          ? min
          : (initial.isAfter(max) ? max : initial),
    );
    if (picked == null) return;
    controller.text = _format(picked);
    onDateChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    return StandardTextField(
      label: label,
      controller: controller,
      readOnly: true,
      onTap: () => _pick(context),
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today_rounded,
            size: 18, color: BaseFormStyles.accent),
        tooltip: 'Pick date',
        onPressed: () => _pick(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 36),
      ),
    );
  }
}

/// Displays a picked [DateTime] with tap-to-open calendar (for state-held dates).
class StandardDatePickerValue extends StatefulWidget {
  const StandardDatePickerValue({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<StandardDatePickerValue> createState() =>
      _StandardDatePickerValueState();
}

class _StandardDatePickerValueState extends State<StandardDatePickerValue> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: BaseFormStyles.formatDateDdMmYyyy(widget.value),
    );
  }

  @override
  void didUpdateWidget(covariant StandardDatePickerValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _ctrl.text = BaseFormStyles.formatDateDdMmYyyy(widget.value);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StandardDatePicker(
      label: widget.label,
      controller: _ctrl,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      onDateChanged: widget.onChanged,
    );
  }
}
