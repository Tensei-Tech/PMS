import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KidnappingExtraFields extends StatefulWidget {
  const KidnappingExtraFields({super.key});

  @override
  State<KidnappingExtraFields> createState() => KidnappingExtraFieldsState();
}

class KidnappingExtraFieldsState extends State<KidnappingExtraFields> {
  static const Color _bgColor = Color(0xFFF4F7F9);
  static const Color _cardColor = Colors.white;
  static const Color _teal = Color(0xFF0EA5E9);
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);
  static const Color _dark = Color(0xFF0F172A);
  static const Color _inputFill = Color(0xFFF8FAFC);
  static const Color _inputBorder = Color(0xFFE2E8F0);
  static const Color _secondary = Color(0xFF64748B);

  final _kidnappedName = TextEditingController();
  final _kidnappedAge = TextEditingController();
  String? _kidnappedGender;
  final _kidnappedOccupation = TextEditingController();
  final _kidnappedMobile = TextEditingController();
  final _kidnappedAadhaar = TextEditingController();
  final _kidnappedReligion = TextEditingController();
  final _kidnappedCaste = TextEditingController();
  final _kidnappedRelation = TextEditingController();

  bool _personFound = false;
  final _foundDate = TextEditingController();
  final _foundTime = TextEditingController();
  final _foundSdNo = TextEditingController();
  bool _statementRecorded = false;
  final _statementDate = TextEditingController();
  final _statementTime = TextEditingController();
  String? _custodyTo;
  final _custodyOtherText = TextEditingController();
  final _custodyName = TextEditingController();
  final _custodyAge = TextEditingController();
  String? _custodyGender;
  final _custodyMobile = TextEditingController();
  final _custodyAadhaar = TextEditingController();
  final _custodyRelation = TextEditingController();
  final _custodyAddress = TextEditingController();

  bool _bnss183Recorded = false;
  final _bnssDate = TextEditingController();
  final _bnssTime = TextEditingController();

  bool _cwcRecorded = false;
  final _cwcDate = TextEditingController();
  final _cwcTime = TextEditingController();

  bool _medicalExamDone = false;
  final _medicalDate = TextEditingController();
  final _medicalTime = TextEditingController();

  bool _inCameraRecorded = false;
  final _inCameraDate = TextEditingController();
  final _inCameraTime = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _kidnappedName,
      _kidnappedAge,
      _kidnappedOccupation,
      _kidnappedMobile,
      _kidnappedAadhaar,
      _kidnappedReligion,
      _kidnappedCaste,
      _kidnappedRelation,
      _foundDate,
      _foundTime,
      _foundSdNo,
      _statementDate,
      _statementTime,
      _custodyOtherText,
      _custodyName,
      _custodyAge,
      _custodyMobile,
      _custodyAadhaar,
      _custodyRelation,
      _custodyAddress,
      _bnssDate,
      _bnssTime,
      _cwcDate,
      _cwcTime,
      _medicalDate,
      _medicalTime,
      _inCameraDate,
      _inCameraTime,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'kidnappedName': _kidnappedName.text.trim(),
      'kidnappedAge': _kidnappedAge.text.trim(),
      'kidnappedGender': _kidnappedGender,
      'kidnappedOccupation': _kidnappedOccupation.text.trim(),
      'kidnappedMobile': _kidnappedMobile.text.trim(),
      'kidnappedAadhaar': _kidnappedAadhaar.text.trim(),
      'kidnappedReligion': _kidnappedReligion.text.trim(),
      'kidnappedCaste': _kidnappedCaste.text.trim(),
      'kidnappedRelation': _kidnappedRelation.text.trim(),
      'personFound': _personFound,
      'foundDate': _foundDate.text.trim(),
      'foundTime': _foundTime.text.trim(),
      'foundSdNo': _foundSdNo.text.trim(),
      'statementRecorded': _statementRecorded,
      'statementDate': _statementDate.text.trim(),
      'statementTime': _statementTime.text.trim(),
      'custodyTo': _custodyTo,
      'custodyOtherText': _custodyOtherText.text.trim(),
      'custodyName': _custodyName.text.trim(),
      'custodyAge': _custodyAge.text.trim(),
      'custodyGender': _custodyGender,
      'custodyMobile': _custodyMobile.text.trim(),
      'custodyAadhaar': _custodyAadhaar.text.trim(),
      'custodyRelation': _custodyRelation.text.trim(),
      'custodyAddress': _custodyAddress.text.trim(),
      'bnss183Recorded': _bnss183Recorded,
      'bnssDate': _bnssDate.text.trim(),
      'bnssTime': _bnssTime.text.trim(),
      'cwcRecorded': _cwcRecorded,
      'cwcDate': _cwcDate.text.trim(),
      'cwcTime': _cwcTime.text.trim(),
      'medicalExamDone': _medicalExamDone,
      'medicalDate': _medicalDate.text.trim(),
      'medicalTime': _medicalTime.text.trim(),
      'inCameraRecorded': _inCameraRecorded,
      'inCameraDate': _inCameraDate.text.trim(),
      'inCameraTime': _inCameraTime.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    _kidnappedName.text = _asString(data['kidnappedName']);
    _kidnappedAge.text = _asString(data['kidnappedAge']);
    _kidnappedGender = _asString(data['kidnappedGender']).isEmpty
        ? null
        : _asString(data['kidnappedGender']);
    _kidnappedOccupation.text = _asString(data['kidnappedOccupation']);
    _kidnappedMobile.text = _asString(data['kidnappedMobile']);
    _kidnappedAadhaar.text = _asString(data['kidnappedAadhaar']);
    _kidnappedReligion.text = _asString(data['kidnappedReligion']);
    _kidnappedCaste.text = _asString(data['kidnappedCaste']);
    _kidnappedRelation.text = _asString(data['kidnappedRelation']);

    _personFound = _asBool(data['personFound']);
    _foundDate.text = _asString(data['foundDate']);
    _foundTime.text = _asString(data['foundTime']);
    _foundSdNo.text = _asString(data['foundSdNo']);
    _statementRecorded = _asBool(data['statementRecorded']);
    _statementDate.text = _asString(data['statementDate']);
    _statementTime.text = _asString(data['statementTime']);
    _custodyTo = _asString(data['custodyTo']).isEmpty
        ? null
        : _asString(data['custodyTo']);
    _custodyOtherText.text = _asString(data['custodyOtherText']);
    _custodyName.text = _asString(data['custodyName']);
    _custodyAge.text = _asString(data['custodyAge']);
    _custodyGender = _asString(data['custodyGender']).isEmpty
        ? null
        : _asString(data['custodyGender']);
    _custodyMobile.text = _asString(data['custodyMobile']);
    _custodyAadhaar.text = _asString(data['custodyAadhaar']);
    _custodyRelation.text = _asString(data['custodyRelation']);
    _custodyAddress.text = _asString(data['custodyAddress']);

    _bnss183Recorded = _asBool(data['bnss183Recorded']);
    _bnssDate.text = _asString(data['bnssDate']);
    _bnssTime.text = _asString(data['bnssTime']);

    _cwcRecorded = _asBool(data['cwcRecorded']);
    _cwcDate.text = _asString(data['cwcDate']);
    _cwcTime.text = _asString(data['cwcTime']);

    _medicalExamDone = _asBool(data['medicalExamDone']);
    _medicalDate.text = _asString(data['medicalDate']);
    _medicalTime.text = _asString(data['medicalTime']);

    _inCameraRecorded = _asBool(data['inCameraRecorded']);
    _inCameraDate.text = _asString(data['inCameraDate']);
    _inCameraTime.text = _asString(data['inCameraTime']);

    setState(() {});
  }

  String _asString(dynamic value) => value?.toString() ?? '';

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _secondary,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: _inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _teal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _sectionTitle(String title, {double fontSize = 13}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _teal,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: _dark,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(Widget child) {
    return Card(
      elevation: 0,
      color: _cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _yesNoToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    Widget buildButton({
      required String text,
      required bool selected,
      required Color selectedColor,
      required VoidCallback onPressed,
    }) {
      final style = selected
          ? ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size.fromHeight(44),
              backgroundColor: selectedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          : OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: _secondary,
              side: const BorderSide(color: _inputBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            );
      return selected
          ? ElevatedButton(
              onPressed: onPressed, style: style, child: Text(text))
          : OutlinedButton(
              onPressed: onPressed, style: style, child: Text(text));
    }

    return Row(
      children: [
        Expanded(
          child: buildButton(
            text: 'YES',
            selected: value,
            selectedColor: _green,
            onPressed: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            text: 'NO',
            selected: !value,
            selectedColor: _red,
            onPressed: () => onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _animatedSwitch(bool flag, Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: flag
          ? Container(key: ValueKey(flag), child: child)
          : const SizedBox.shrink(key: ValueKey(false)),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d-$m-$y';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = _parseDate(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => controller.text = _formatDate(picked));
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final initial = _parseTime(controller.text) ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() => controller.text = _formatTime(picked));
    }
  }

  Widget _dateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(),
      decoration: _inputDecoration(label).copyWith(
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: () => _pickDate(controller),
    );
  }

  Widget _timeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(),
      decoration: _inputDecoration(label).copyWith(
        suffixIcon: const Icon(Icons.access_time_rounded),
      ),
      onTap: () => _pickTime(controller),
    );
  }

  Widget _responsiveTwoFieldRow({
    required BuildContext context,
    required Widget first,
    required Widget second,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 400) {
      return Column(
        children: [
          first,
          const SizedBox(height: 12),
          second,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  String _custodyKycTitle() {
    if ((_custodyTo ?? '').isEmpty) return 'CUSTODY KYC DETAILS';
    if (_custodyTo == 'Other') {
      final t = _custodyOtherText.text.trim();
      return t.isEmpty ? 'OTHER KYC DETAILS' : '${t.toUpperCase()} KYC DETAILS';
    }
    return '${_custodyTo!.toUpperCase()} KYC DETAILS';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: Column(
        children: [
          _sectionCard(
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: _sectionTitle('Kidnapped Person KYC'),
                initiallyExpanded: false,
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 12),
                children: [
                  _responsiveTwoFieldRow(
                    context: context,
                    first: TextFormField(
                      controller: _kidnappedName,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Name'),
                    ),
                    second: TextFormField(
                      controller: _kidnappedAge,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Age'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _responsiveTwoFieldRow(
                    context: context,
                    first: DropdownButtonFormField<String>(
                      key:
                          ValueKey('kidnappedGender_${_kidnappedGender ?? ''}'),
                      initialValue: _kidnappedGender,
                      decoration: _inputDecoration('Gender'),
                      style: GoogleFonts.poppins(color: _dark),
                      items: const ['Male', 'Female', 'Other']
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e, style: GoogleFonts.poppins()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _kidnappedGender = v),
                    ),
                    second: TextFormField(
                      controller: _kidnappedOccupation,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Occupation'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _responsiveTwoFieldRow(
                    context: context,
                    first: TextFormField(
                      controller: _kidnappedMobile,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Mobile Number'),
                    ),
                    second: TextFormField(
                      controller: _kidnappedAadhaar,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Aadhaar Number'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _responsiveTwoFieldRow(
                    context: context,
                    first: TextFormField(
                      controller: _kidnappedReligion,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Religion'),
                    ),
                    second: TextFormField(
                      controller: _kidnappedCaste,
                      style: GoogleFonts.poppins(),
                      decoration: _inputDecoration('Caste'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kidnappedRelation,
                    style: GoogleFonts.poppins(),
                    decoration: _inputDecoration('Relation with Complainant'),
                  ),
                ],
              ),
            ),
          ),
          _sectionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Found Status'),
                const SizedBox(height: 12),
                _yesNoToggle(
                  value: _personFound,
                  onChanged: (v) => setState(() => _personFound = v),
                ),
                const SizedBox(height: 12),
                _animatedSwitch(
                  _personFound,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _responsiveTwoFieldRow(
                        context: context,
                        first: _dateField('Found Date', _foundDate),
                        second: _timeField('Found Time', _foundTime),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _foundSdNo,
                        style: GoogleFonts.poppins(),
                        decoration:
                            _inputDecoration('SD No. / Station Diary No.'),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Statement of kidnapped person recorded?',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _yesNoToggle(
                        value: _statementRecorded,
                        onChanged: (v) =>
                            setState(() => _statementRecorded = v),
                      ),
                      const SizedBox(height: 12),
                      _animatedSwitch(
                        _statementRecorded,
                        Column(
                          children: [
                            _responsiveTwoFieldRow(
                              context: context,
                              first:
                                  _dateField('Statement Date', _statementDate),
                              second:
                                  _timeField('Statement Time', _statementTime),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        key: ValueKey('custodyTo_${_custodyTo ?? ''}'),
                        initialValue: _custodyTo,
                        decoration: _inputDecoration('Custody Given To'),
                        style: GoogleFonts.poppins(color: _dark),
                        items: const [
                          'Parents',
                          'Relative',
                          'Friend',
                          'Shelter Home',
                          'Other',
                        ]
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e, style: GoogleFonts.poppins()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _custodyTo = v),
                      ),
                      const SizedBox(height: 12),
                      _animatedSwitch(
                        _custodyTo == 'Other',
                        TextFormField(
                          controller: _custodyOtherText,
                          style: GoogleFonts.poppins(),
                          decoration: _inputDecoration('Please Specify'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _animatedSwitch(
                        (_custodyTo ?? '').isNotEmpty,
                        Container(
                          key: ValueKey(_custodyKycTitle()),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _inputBorder),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(
                                _custodyKycTitle(),
                                fontSize: 12,
                              ),
                              const SizedBox(height: 12),
                              _responsiveTwoFieldRow(
                                context: context,
                                first: TextFormField(
                                  controller: _custodyName,
                                  style: GoogleFonts.poppins(),
                                  decoration: _inputDecoration('Name'),
                                ),
                                second: TextFormField(
                                  controller: _custodyAge,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.poppins(),
                                  decoration: _inputDecoration('Age'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _responsiveTwoFieldRow(
                                context: context,
                                first: DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    'custodyGender_${_custodyGender ?? ''}',
                                  ),
                                  initialValue: _custodyGender,
                                  decoration: _inputDecoration('Gender'),
                                  style: GoogleFonts.poppins(color: _dark),
                                  items: const ['Male', 'Female', 'Other']
                                      .map(
                                        (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _custodyGender = v),
                                ),
                                second: TextFormField(
                                  controller: _custodyMobile,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.poppins(),
                                  decoration: _inputDecoration('Mobile Number'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _responsiveTwoFieldRow(
                                context: context,
                                first: TextFormField(
                                  controller: _custodyAadhaar,
                                  style: GoogleFonts.poppins(),
                                  decoration:
                                      _inputDecoration('Aadhaar Number'),
                                ),
                                second: TextFormField(
                                  controller: _custodyRelation,
                                  style: GoogleFonts.poppins(),
                                  decoration: _inputDecoration('Relationship'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _custodyAddress,
                                maxLines: 3,
                                style: GoogleFonts.poppins(),
                                decoration: _inputDecoration('Full Address'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _sectionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('183 BNSS'),
                const SizedBox(height: 12),
                Text(
                  'Statement Recorded under 183 BNSS?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 8),
                _yesNoToggle(
                  value: _bnss183Recorded,
                  onChanged: (v) => setState(() => _bnss183Recorded = v),
                ),
                const SizedBox(height: 12),
                _animatedSwitch(
                  _bnss183Recorded,
                  _responsiveTwoFieldRow(
                    context: context,
                    first: _dateField('Statement Date', _bnssDate),
                    second: _timeField('Statement Time', _bnssTime),
                  ),
                ),
              ],
            ),
          ),
          _sectionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('CWC Statement'),
                const SizedBox(height: 12),
                Text(
                  'Statement Recorded before Child Welfare Committee (CWC)?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 8),
                _yesNoToggle(
                  value: _cwcRecorded,
                  onChanged: (v) => setState(() => _cwcRecorded = v),
                ),
                const SizedBox(height: 12),
                _animatedSwitch(
                  _cwcRecorded,
                  _responsiveTwoFieldRow(
                    context: context,
                    first: _dateField('CWC Statement Date', _cwcDate),
                    second: _timeField('CWC Statement Time', _cwcTime),
                  ),
                ),
              ],
            ),
          ),
          _sectionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Medical Examination'),
                const SizedBox(height: 12),
                Text(
                  'Medical Examination Conducted?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 8),
                _yesNoToggle(
                  value: _medicalExamDone,
                  onChanged: (v) => setState(() => _medicalExamDone = v),
                ),
                const SizedBox(height: 12),
                _animatedSwitch(
                  _medicalExamDone,
                  _responsiveTwoFieldRow(
                    context: context,
                    first: _dateField('Medical Examination Date', _medicalDate),
                    second:
                        _timeField('Medical Examination Time', _medicalTime),
                  ),
                ),
              ],
            ),
          ),
          _sectionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('In-Camera Statement'),
                const SizedBox(height: 12),
                Text(
                  'In-Camera Statement Recorded?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 8),
                _yesNoToggle(
                  value: _inCameraRecorded,
                  onChanged: (v) => setState(() => _inCameraRecorded = v),
                ),
                const SizedBox(height: 12),
                _animatedSwitch(
                  _inCameraRecorded,
                  _responsiveTwoFieldRow(
                    context: context,
                    first:
                        _dateField('In-Camera Statement Date', _inCameraDate),
                    second:
                        _timeField('In-Camera Statement Time', _inCameraTime),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
