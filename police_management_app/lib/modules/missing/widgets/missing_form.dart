// lib/modules/missing/widgets/missing_form.dart
// Standalone Missing form — helpers duplicated from nc_form.dart + kidnapping_extra_fields.dart patterns.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_constants.dart';
import '../../../widgets/base_form/base_form.dart';

// ── Palette (matches nc_form.dart / common_form.dart) ─────────────────────────
const Color _kDark = Color(0xFF0f172a);
const Color _kMid = Color(0xFF1e293b);
const Color _kTeal = Color(0xFF0ea5e9);
const Color _kRed = Color(0xFFef4444);
const Color _kSec = Color(0xFF64748b);
const Color _kMuted = Color(0xFF94a3b8);
const Color _kInputBg = Color(0xFFf8fafc);
const Color _kBorder = Color(0xFFe2e8f0);
const Color _kCardBg = Color(0xFFffffff);
const Color _kPageBg = Color(0xFFf4f7f9);

// Kidnapping extra palette (kidnapping_extra_fields.dart)
const Color _kKidCardColor = Colors.white;
const Color _kKidGreen = Color(0xFF10B981);
const Color _kKidRed = Color(0xFFEF4444);
const Color _kKidDark = Color(0xFF0F172A);
const Color _kKidInputFill = Color(0xFFF8FAFC);
const Color _kKidInputBorder = Color(0xFFE2E8F0);
const Color _kKidSecondary = Color(0xFF64748B);

const _tsLabel = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: _kDark,
  letterSpacing: 0.3,
);
const _tsSection = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: _kDark,
  letterSpacing: 0.5,
);
const _tsMuted = TextStyle(fontSize: 11, color: _kMuted);

const _kGenders = ['Male', 'Female', 'Other'];

const String _kAgeMinorErr =
    'Person below 18 years cannot be registered as Missing. Please register under Kidnapping.';

class _SuspectedRow {
  final name = TextEditingController();
  final age = TextEditingController();
  String gender = 'Male';
  final mobile = TextEditingController();
  final aadhaar = TextEditingController();
  final address = TextEditingController();

  void dispose() {
    name.dispose();
    age.dispose();
    mobile.dispose();
    aadhaar.dispose();
    address.dispose();
  }

  Map<String, dynamic> toMap() => {
        'name': name.text.trim(),
        'age': age.text.trim(),
        'gender': gender,
        'mobile': mobile.text.trim(),
        'aadhaar': aadhaar.text.trim(),
        'address': address.text.trim(),
      };

  void hydrate(Map<String, dynamic> m) {
    name.text = _str(m['name']);
    age.text = _str(m['age']);
    final g = m['gender']?.toString();
    if (g != null && _kGenders.contains(g)) gender = g;
    mobile.text = _str(m['mobile']);
    aadhaar.text = _str(m['aadhaar']);
    address.text = _str(m['address']);
  }

  static String _str(dynamic v) => v?.toString() ?? '';
}

class MissingForm extends StatefulWidget {
  const MissingForm({super.key});

  @override
  State<MissingForm> createState() => MissingFormState();
}

class MissingFormState extends State<MissingForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> scrollProgress = ValueNotifier(0);
  String saveBarText = 'All changes unsaved';

  // §1
  final _missingNumber = TextEditingController();

  // §2 Missing person
  final _mpName = TextEditingController();
  final _mpAge = TextEditingController();
  String _mpGender = 'Male';
  final _mpOcc = TextEditingController();
  final _mpMobile = TextEditingController();
  final _mpAadhaar = TextEditingController();
  final _mpReligion = TextEditingController();
  final _mpCaste = TextEditingController();
  final _mpAddress = TextEditingController();
  final _mpSocial = TextEditingController();
  final _mpWhatsapp = TextEditingController();

  // §3
  final List<_SuspectedRow> _suspected = [];

  // §4
  final _reason = TextEditingController();
  int _reasonWords = 0;

  // §5 Complainant
  final _compName = TextEditingController();
  final _compAge = TextEditingController();
  String _compGender = 'Male';
  final _compOcc = TextEditingController();
  final _compMobile = TextEditingController();
  final _compAadhaar = TextEditingController();
  final _compPan = TextEditingController();
  final _compReligion = TextEditingController();
  final _compCaste = TextEditingController();

  // §6–§7
  String _regDesig = 'HC';
  final _registrarName = TextEditingController();
  String _ioDesig = 'PSI';
  final _ioName = TextEditingController();

  // §8
  final _lastKnown = TextEditingController();
  int _lastKnownWords = 0;

  // §9 CCTV
  bool _cctvRecorded = false;
  final _cctvDate = TextEditingController();
  final _cctvTime = TextEditingController();

  // §10–§12 (dd/MM/yyyy)
  final _cdrSentDate = TextEditingController();
  final _outwardNum = TextEditingController();
  final _outwardDate = TextEditingController();
  final _cdrReceivedDate = TextEditingController();

  // §13 Found
  bool _foundReported = false;
  final _foundDate = TextEditingController();
  final _foundTime = TextEditingController();
  final _foundSd = TextEditingController();
  final _foundVillage = TextEditingController();
  final _foundAreaName = TextEditingController();
  final _foundFullAddress = TextEditingController();

  // §14 Custody (kidnapping_extra_fields Found Status custody block)
  String? _custodyTo;
  final _custodyOtherText = TextEditingController();
  final _custodyName = TextEditingController();
  final _custodyAge = TextEditingController();
  String? _custodyGender;
  final _custodyMobile = TextEditingController();
  final _custodyAadhaar = TextEditingController();
  final _custodyRelation = TextEditingController();
  final _custodyAddress = TextEditingController();

  // §15
  final _remark = TextEditingController();
  int _remarkWords = 0;

  // §16–§19
  bool _statement164183Recorded = false;
  final _s164Date = TextEditingController();
  final _s164Time = TextEditingController();

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
    _scroll.dispose();
    scrollProgress.dispose();
    _missingNumber.dispose();
    _mpName.dispose();
    _mpAge.dispose();
    _mpOcc.dispose();
    _mpMobile.dispose();
    _mpAadhaar.dispose();
    _mpReligion.dispose();
    _mpCaste.dispose();
    _mpAddress.dispose();
    _mpSocial.dispose();
    _mpWhatsapp.dispose();
    for (final s in _suspected) {
      s.dispose();
    }
    _reason.dispose();
    _compName.dispose();
    _compAge.dispose();
    _compOcc.dispose();
    _compMobile.dispose();
    _compAadhaar.dispose();
    _compPan.dispose();
    _compReligion.dispose();
    _compCaste.dispose();
    _registrarName.dispose();
    _ioName.dispose();
    _lastKnown.dispose();
    _cctvDate.dispose();
    _cctvTime.dispose();
    _cdrSentDate.dispose();
    _outwardNum.dispose();
    _outwardDate.dispose();
    _cdrReceivedDate.dispose();
    _foundDate.dispose();
    _foundTime.dispose();
    _foundSd.dispose();
    _foundVillage.dispose();
    _foundAreaName.dispose();
    _foundFullAddress.dispose();
    _custodyOtherText.dispose();
    _custodyName.dispose();
    _custodyAge.dispose();
    _custodyMobile.dispose();
    _custodyAadhaar.dispose();
    _custodyRelation.dispose();
    _custodyAddress.dispose();
    _remark.dispose();
    _s164Date.dispose();
    _s164Time.dispose();
    _cwcDate.dispose();
    _cwcTime.dispose();
    _medicalDate.dispose();
    _medicalTime.dispose();
    _inCameraDate.dispose();
    _inCameraTime.dispose();
    super.dispose();
  }

  bool _onScrollNotif(ScrollNotification n) {
    final mx = n.metrics.maxScrollExtent;
    if (mx <= 0) {
      scrollProgress.value = 0;
      return false;
    }
    final p = (n.metrics.pixels / mx).clamp(0.0, 1.0);
    if ((p - scrollProgress.value).abs() > 0.004) scrollProgress.value = p;
    return false;
  }

  void markLoadedFromRecord() {
    setState(() => saveBarText = 'Loaded from record');
  }

  void saveDraft() {
    setState(() =>
        saveBarText = 'Draft saved · ${TimeOfDay.now().format(context)}');
  }

  void clearForm() {
    _missingNumber.clear();
    _mpName.clear();
    _mpAge.clear();
    _mpGender = 'Male';
    _mpOcc.clear();
    _mpMobile.clear();
    _mpAadhaar.clear();
    _mpReligion.clear();
    _mpCaste.clear();
    _mpAddress.clear();
    _mpSocial.clear();
    _mpWhatsapp.clear();
    for (final s in _suspected) {
      s.dispose();
    }
    _suspected.clear();
    _reason.clear();
    _reasonWords = 0;
    _compName.clear();
    _compAge.clear();
    _compGender = 'Male';
    _compOcc.clear();
    _compMobile.clear();
    _compAadhaar.clear();
    _compPan.clear();
    _compReligion.clear();
    _compCaste.clear();
    _regDesig = 'HC';
    _registrarName.clear();
    _ioDesig = 'PSI';
    _ioName.clear();
    _lastKnown.clear();
    _lastKnownWords = 0;
    _cctvRecorded = false;
    _cctvDate.clear();
    _cctvTime.clear();
    _cdrSentDate.clear();
    _outwardNum.clear();
    _outwardDate.clear();
    _cdrReceivedDate.clear();
    _foundReported = false;
    _foundDate.clear();
    _foundTime.clear();
    _foundSd.clear();
    _foundVillage.clear();
    _foundAreaName.clear();
    _foundFullAddress.clear();
    _custodyTo = null;
    _custodyOtherText.clear();
    _custodyName.clear();
    _custodyAge.clear();
    _custodyGender = null;
    _custodyMobile.clear();
    _custodyAadhaar.clear();
    _custodyRelation.clear();
    _custodyAddress.clear();
    _remark.clear();
    _remarkWords = 0;
    _statement164183Recorded = false;
    _s164Date.clear();
    _s164Time.clear();
    _cwcRecorded = false;
    _cwcDate.clear();
    _cwcTime.clear();
    _medicalExamDone = false;
    _medicalDate.clear();
    _medicalTime.clear();
    _inCameraRecorded = false;
    _inCameraDate.clear();
    _inCameraTime.clear();
    saveBarText = 'All changes unsaved';
    setState(() {});
  }

  void _onWordCapChanged(TextEditingController c, void Function(int) setCt) {
    final words = c.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (words.length > 25) {
      final allowed = words.take(25).join(' ');
      c.value = TextEditingValue(
        text: allowed,
        selection: TextSelection.collapsed(offset: allowed.length),
      );
      setCt(25);
      setState(() {});
      return;
    }
    setCt(words.length);
    setState(() {});
  }

  void _recountWords(TextEditingController c, void Function(int) setCt) {
    final words = c.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    setCt(words.length > 25 ? 25 : words.length);
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  // ── kidnapping-style dd-MM-yyyy date/time (kidnapping_extra_fields.dart) ─────
  String _formatKidnapDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d-$m-$y';
  }

  String _formatKidnapTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime? _parseKidnapDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  TimeOfDay? _parseKidnapTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _pickKidnapDate(TextEditingController controller) async {
    final initial = _parseKidnapDate(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => controller.text = _formatKidnapDate(picked));
    }
  }

  Future<void> _pickKidnapTime(TextEditingController controller) async {
    final initial = _parseKidnapTime(controller.text) ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() => controller.text = _formatKidnapTime(picked));
    }
  }

  InputDecoration _kidInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _kKidSecondary,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: _kKidInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kKidInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kKidInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kTeal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _kidSectionTitle(String title, {double fontSize = 13}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _kTeal,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: _kKidDark,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _kidSectionCard(Widget child) {
    return Card(
      elevation: 0,
      color: _kKidCardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _kKidInputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _kidYesNoToggle({
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
              foregroundColor: _kKidSecondary,
              side: const BorderSide(color: _kKidInputBorder),
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
            selectedColor: _kKidGreen,
            onPressed: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildButton(
            text: 'NO',
            selected: !value,
            selectedColor: _kKidRed,
            onPressed: () => onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _kidAnimatedSwitch(bool flag, Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: flag
          ? Container(key: ValueKey(flag), child: child)
          : const SizedBox.shrink(key: ValueKey(false)),
    );
  }

  Widget _kidDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(),
      decoration: _kidInputDecoration(label).copyWith(
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: () => _pickKidnapDate(controller),
    );
  }

  Widget _kidTimeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(),
      decoration: _kidInputDecoration(label).copyWith(
        suffixIcon: const Icon(Icons.access_time_rounded),
      ),
      onTap: () => _pickKidnapTime(controller),
    );
  }

  Widget _kidResponsiveTwoFieldRow({
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

  Widget _row(List<Widget> children) =>
      StandardFormFieldRow(children: children);

  Widget _tf(
    String label,
    TextEditingController ctrl, {
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return StandardTextField(
      label: label,
      controller: ctrl,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _chipSelector({
    required String label,
    required List<String> items,
    required String? selected,
    required ValueChanged<String> onSelect,
    Color activeColor = _kTeal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _tsLabel),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              final active = selected == item;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => onSelect(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? activeColor.withValues(alpha: 0.1)
                          : _kInputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? activeColor : _kBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? activeColor : _kSec,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _addBtn(String label, VoidCallback onTap) => Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add, size: 14),
          label: Text(label, style: const TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            foregroundColor: _kTeal,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );

  Widget _emptyBox(String t) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: _kInputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder, style: BorderStyle.solid),
        ),
        child: Text(t, textAlign: TextAlign.center, style: _tsMuted),
      );

  Widget _barBtn(String label, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _card(int idx, String title, Widget body,
      {bool startOpen = false, bool useExpansion = false}) {
    final leadingBadge = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: _kMid,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text('$idx',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      ),
    );
    final themed = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    Widget inner;
    if (useExpansion) {
      inner = ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        initiallyExpanded: startOpen,
        leading: leadingBadge,
        title: Text(title, style: _tsSection),
        children: [body],
      );
    } else {
      inner = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leadingBadge,
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: _tsSection)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [body],
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _kCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _kBorder),
      ),
      child: Theme(
        data: themed,
        child: inner,
      ),
    );
  }

  Widget _slashDateRow(String label, TextEditingController c) =>
      StandardFormFieldRow(children: [
        StandardDatePicker(
          label: '$label (dd/MM/yyyy)',
          controller: c,
          lastDate: DateTime.now(),
          onDateChanged: (_) => setState(() {}),
        ),
      ]);

  void _addSuspected() {
    setState(() => _suspected.add(_SuspectedRow()));
  }

  void _removeSuspected(int i) {
    final r = _suspected.removeAt(i);
    r.dispose();
    setState(() {});
  }

  Widget _suspectedCard(int i, _SuspectedRow r) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Person #${i + 1}',
                      style: _tsSection.copyWith(fontSize: 11))),
              TextButton(
                onPressed: () => _removeSuspected(i),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: _kRed,
                ),
                child: const Text('✕ Remove', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _row([
            _tf('Name', r.name),
            _tf('Age', r.age, keyboardType: TextInputType.number),
          ]),
          _chipSelector(
            label: 'Gender',
            items: _kGenders,
            selected: r.gender,
            onSelect: (v) => setState(() => r.gender = v),
          ),
          const SizedBox(height: 8),
          _row([
            _tf('Mobile', r.mobile, keyboardType: TextInputType.phone),
            _tf('Aadhaar', r.aadhaar),
          ]),
          _row([_tf('Address', r.address, maxLines: 3)]),
        ],
      ),
    );
  }

  Map<String, dynamic> buildDocumentMap() {
    return {
      'missingNumber': _missingNumber.text.trim(),
      'missingPerson': {
        'name': _mpName.text.trim(),
        'age': _mpAge.text.trim(),
        'gender': _mpGender,
        'occupation': _mpOcc.text.trim(),
        'mobile': _mpMobile.text.trim(),
        'aadhaar': _mpAadhaar.text.trim(),
        'religion': _mpReligion.text.trim(),
        'caste': _mpCaste.text.trim(),
        'address': _mpAddress.text.trim(),
        'activeSocialMedia': _mpSocial.text.trim(),
        'whatsapp': _mpWhatsapp.text.trim(),
      },
      'suspectedPersons': _suspected.map((e) => e.toMap()).toList(),
      'reason': _reason.text.trim(),
      'complainant': {
        'name': _compName.text.trim(),
        'age': _compAge.text.trim(),
        'gender': _compGender,
        'occ': _compOcc.text.trim(),
        'mobile': _compMobile.text.trim(),
        'aadhaar': _compAadhaar.text.trim(),
        'pan': _compPan.text.trim(),
        'religion': _compReligion.text.trim(),
        'caste': _compCaste.text.trim(),
      },
      'registeredBy': {
        'designation': _regDesig,
        'name': _registrarName.text.trim(),
      },
      'investigationOfficer': {
        'designation': _ioDesig,
        'name': _ioName.text.trim(),
      },
      'lastKnownDirection': _lastKnown.text.trim(),
      'cctv': {
        'recorded': _cctvRecorded,
        'date': _cctvDate.text.trim(),
        'time': _cctvTime.text.trim(),
      },
      'cdrSentDate': _cdrSentDate.text.trim(),
      'outward': {
        'number': _outwardNum.text.trim(),
        'date': _outwardDate.text.trim(),
      },
      'cdrReceivedDate': _cdrReceivedDate.text.trim(),
      'found': {
        'reported': _foundReported,
        'date': _foundDate.text.trim(),
        'time': _foundTime.text.trim(),
        'sdNumber': _foundSd.text.trim(),
        'village': _foundVillage.text.trim(),
        'areaName': _foundAreaName.text.trim(),
        'fullAddress': _foundFullAddress.text.trim(),
      },
      'custody': {
        'custodyTo': _custodyTo,
        'custodyOtherText': _custodyOtherText.text.trim(),
        'custodyName': _custodyName.text.trim(),
        'custodyAge': _custodyAge.text.trim(),
        'custodyGender': _custodyGender,
        'custodyMobile': _custodyMobile.text.trim(),
        'custodyAadhaar': _custodyAadhaar.text.trim(),
        'custodyRelation': _custodyRelation.text.trim(),
        'custodyAddress': _custodyAddress.text.trim(),
      },
      'remark': _remark.text.trim(),
      'statement164183Recorded': _statement164183Recorded,
      'statement164183Date': _s164Date.text.trim(),
      'statement164183Time': _s164Time.text.trim(),
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

  static bool _bool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return false;
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  void hydrateFromMap(Map<String, dynamic> data) {
    _missingNumber.text = _str(data['missingNumber']);

    final mp = data['missingPerson'];
    if (mp is Map) {
      _mpName.text = _str(mp['name']);
      _mpAge.text = _str(mp['age']);
      final g = mp['gender']?.toString();
      if (g != null && _kGenders.contains(g)) _mpGender = g;
      _mpOcc.text = _str(mp['occupation']);
      _mpMobile.text = _str(mp['mobile']);
      _mpAadhaar.text = _str(mp['aadhaar']);
      _mpReligion.text = _str(mp['religion']);
      _mpCaste.text = _str(mp['caste']);
      _mpAddress.text = _str(mp['address']);
      _mpSocial.text = _str(mp['activeSocialMedia']);
      _mpWhatsapp.text = _str(mp['whatsapp']);
    }

    for (final s in _suspected) {
      s.dispose();
    }
    _suspected.clear();
    final susp = data['suspectedPersons'];
    if (susp is List) {
      for (final item in susp) {
        if (item is Map) {
          final row = _SuspectedRow();
          row.hydrate(Map<String, dynamic>.from(item));
          _suspected.add(row);
        }
      }
    }

    _reason.text = _str(data['reason']);
    _recountWords(_reason, (n) => _reasonWords = n);

    final comp = data['complainant'];
    if (comp is Map) {
      _compName.text = _str(comp['name']);
      _compAge.text = _str(comp['age']);
      final g = comp['gender']?.toString();
      if (g != null && _kGenders.contains(g)) _compGender = g;
      _compOcc.text = _str(comp['occ']);
      _compMobile.text = _str(comp['mobile']);
      _compAadhaar.text = _str(comp['aadhaar']);
      _compPan.text = _str(comp['pan']);
      _compReligion.text = _str(comp['religion']);
      _compCaste.text = _str(comp['caste']);
    }

    final reg = data['registeredBy'];
    if (reg is Map) {
      final d = reg['designation']?.toString();
      if (d != null && PoliceDesignations.formIoAndReg.contains(d)) _regDesig = d;
      _registrarName.text = _str(reg['name']);
    }
    final io = data['investigationOfficer'];
    if (io is Map) {
      final d = io['designation']?.toString();
      if (d != null && PoliceDesignations.formIoAndReg.contains(d)) _ioDesig = d;
      _ioName.text = _str(io['name']);
    }

    _lastKnown.text = _str(data['lastKnownDirection']);
    _recountWords(_lastKnown, (n) => _lastKnownWords = n);

    final cctv = data['cctv'];
    if (cctv is Map) {
      _cctvRecorded = _bool(cctv['recorded']);
      _cctvDate.text = _str(cctv['date']);
      _cctvTime.text = _str(cctv['time']);
    }

    _cdrSentDate.text = _str(data['cdrSentDate']);

    final outward = data['outward'];
    if (outward is Map) {
      _outwardNum.text = _str(outward['number']);
      _outwardDate.text = _str(outward['date']);
    }

    _cdrReceivedDate.text = _str(data['cdrReceivedDate']);

    final found = data['found'];
    if (found is Map) {
      _foundReported = _bool(found['reported']);
      _foundDate.text = _str(found['date']);
      _foundTime.text = _str(found['time']);
      _foundSd.text = _str(found['sdNumber']);
      _foundVillage.text = _str(found['village']);
      _foundAreaName.text = _str(found['areaName']);
      _foundFullAddress.text = _str(found['fullAddress']);
    }

    final custody = data['custody'];
    if (custody is Map) {
      final ct = _str(custody['custodyTo']);
      _custodyTo = ct.isEmpty ? null : ct;
      _custodyOtherText.text = _str(custody['custodyOtherText']);
      _custodyName.text = _str(custody['custodyName']);
      _custodyAge.text = _str(custody['custodyAge']);
      final cg = _str(custody['custodyGender']);
      _custodyGender = cg.isEmpty ? null : cg;
      _custodyMobile.text = _str(custody['custodyMobile']);
      _custodyAadhaar.text = _str(custody['custodyAadhaar']);
      _custodyRelation.text = _str(custody['custodyRelation']);
      _custodyAddress.text = _str(custody['custodyAddress']);
    }

    _remark.text = _str(data['remark']);
    _recountWords(_remark, (n) => _remarkWords = n);

    _statement164183Recorded = _bool(data['statement164183Recorded']);
    _s164Date.text = _str(data['statement164183Date']);
    _s164Time.text = _str(data['statement164183Time']);

    _cwcRecorded = _bool(data['cwcRecorded']);
    _cwcDate.text = _str(data['cwcDate']);
    _cwcTime.text = _str(data['cwcTime']);

    _medicalExamDone = _bool(data['medicalExamDone']);
    _medicalDate.text = _str(data['medicalDate']);
    _medicalTime.text = _str(data['medicalTime']);

    _inCameraRecorded = _bool(data['inCameraRecorded']);
    _inCameraDate.text = _str(data['inCameraDate']);
    _inCameraTime.text = _str(data['inCameraTime']);

    setState(() {});
  }

  Widget _sMissingPersonBody() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row([
            _tf('Name', _mpName),
            _tf(
              'Age',
              _mpAge,
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n != null && n < 18) return _kAgeMinorErr;
                return null;
              },
            ),
          ]),
          _chipSelector(
            label: 'Gender',
            items: _kGenders,
            selected: _mpGender,
            onSelect: (v) => setState(() => _mpGender = v),
          ),
          const SizedBox(height: 8),
          _row([_tf('Occupation', _mpOcc)]),
          _row([
            _tf('Mobile', _mpMobile, keyboardType: TextInputType.phone),
            _tf('Aadhaar', _mpAadhaar),
          ]),
          _row([
            _tf('Religion', _mpReligion),
            _tf('Caste', _mpCaste),
          ]),
          _row([_tf('Address', _mpAddress, maxLines: 3)]),
          _row([_tf('Active Social Media Accounts', _mpSocial)]),
          _row([
            _tf('WhatsApp Number', _mpWhatsapp,
                keyboardType: TextInputType.phone),
          ]),
        ],
      );

  Widget _sComplainantBody() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row([
            _tf('Name', _compName),
            _tf('Age', _compAge, keyboardType: TextInputType.number),
          ]),
          _chipSelector(
            label: 'Gender',
            items: _kGenders,
            selected: _compGender,
            onSelect: (v) => setState(() => _compGender = v),
          ),
          const SizedBox(height: 8),
          _row([_tf('Occupation', _compOcc)]),
          _row([
            _tf('Mobile', _compMobile, keyboardType: TextInputType.phone),
            _tf('Aadhaar', _compAadhaar),
          ]),
          _row([_tf('PAN', _compPan)]),
          _row([
            _tf('Religion', _compReligion),
            _tf('Caste', _compCaste),
          ]),
        ],
      );

  Widget _custodyBlock(BuildContext ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('custodyTo_${_custodyTo ?? ''}'),
            initialValue: _custodyTo,
            decoration: _kidInputDecoration('Custody Given To'),
            style: GoogleFonts.poppins(color: _kKidDark),
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
          _kidAnimatedSwitch(
            _custodyTo == 'Other',
            TextFormField(
              controller: _custodyOtherText,
              style: GoogleFonts.poppins(),
              decoration: _kidInputDecoration('Please Specify'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          _kidAnimatedSwitch(
            (_custodyTo ?? '').isNotEmpty,
            Container(
              key: ValueKey(_custodyKycTitle()),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kKidInputBorder),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kidSectionTitle(
                    _custodyKycTitle(),
                    fontSize: 12,
                  ),
                  const SizedBox(height: 12),
                  _kidResponsiveTwoFieldRow(
                    context: ctx,
                    first: TextFormField(
                      controller: _custodyName,
                      style: GoogleFonts.poppins(),
                      decoration: _kidInputDecoration('Name'),
                    ),
                    second: TextFormField(
                      controller: _custodyAge,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(),
                      decoration: _kidInputDecoration('Age'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _kidResponsiveTwoFieldRow(
                    context: ctx,
                    first: DropdownButtonFormField<String>(
                      key: ValueKey(
                        'custodyGender_${_custodyGender ?? ''}',
                      ),
                      initialValue: _custodyGender,
                      decoration: _kidInputDecoration('Gender'),
                      style: GoogleFonts.poppins(color: _kKidDark),
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
                      decoration: _kidInputDecoration('Mobile Number'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _kidResponsiveTwoFieldRow(
                    context: ctx,
                    first: TextFormField(
                      controller: _custodyAadhaar,
                      style: GoogleFonts.poppins(),
                      decoration:
                          _kidInputDecoration('Aadhaar Number'),
                    ),
                    second: TextFormField(
                      controller: _custodyRelation,
                      style: GoogleFonts.poppins(),
                      decoration: _kidInputDecoration('Relationship'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _custodyAddress,
                    maxLines: 3,
                    style: GoogleFonts.poppins(),
                    decoration: _kidInputDecoration('Full Address'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kPageBg,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotif,
        child: Column(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: scrollProgress,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 3,
                color: _kTeal,
                backgroundColor: _kBorder,
              ),
            ),
            Container(
              color: _kCardBg,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(saveBarText, style: _tsMuted)),
                  _barBtn('Clear', Icons.refresh_outlined, clearForm, _kRed),
                  const SizedBox(width: 6),
                  _barBtn(
                      'Save Draft', Icons.save_outlined, saveDraft, _kTeal),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scroll,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  children: [
                    BaseFormContent.scrollSections(
                      children: [
                      _card(1, 'Missing Number',
                          _row([_tf('Missing Number', _missingNumber)]),
                          startOpen: true),
                    _card(2, 'Missing Person KYC', _sMissingPersonBody(),
                        startOpen: false, useExpansion: true),
                    _card(
                      3,
                      'With Whom / Suspected',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _addBtn('+ Add Person', _addSuspected),
                          if (_suspected.isEmpty)
                            _emptyBox('No persons added.')
                          else
                            ..._suspected.asMap().entries.map(
                                  (e) => _suspectedCard(e.key, e.value),
                                ),
                        ],
                      ),
                    ),
                    _card(
                      4,
                      'Reason',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tf(
                            'Reason',
                            _reason,
                            maxLines: 5,
                            onChanged: (v) =>
                                _onWordCapChanged(_reason, (n) => _reasonWords = n),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$_reasonWords / 25 words',
                              style: _tsMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _card(5, 'Complainant KYC', _sComplainantBody(),
                        useExpansion: true),
                    _card(
                      6,
                      'Registered By',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _chipSelector(
                            label: 'Designation',
                            items: PoliceDesignations.formIoAndReg,
                            selected: _regDesig,
                            onSelect: (v) => setState(() => _regDesig = v),
                          ),
                          const SizedBox(height: 8),
                          _row([_tf('Registrar Name', _registrarName)]),
                        ],
                      ),
                    ),
                    _card(
                      7,
                      'Investigation Officer',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _chipSelector(
                            label: 'Designation',
                            items: PoliceDesignations.formIoAndReg,
                            selected: _ioDesig,
                            onSelect: (v) => setState(() => _ioDesig = v),
                          ),
                          const SizedBox(height: 8),
                          _row([_tf('IO Name', _ioName)]),
                        ],
                      ),
                    ),
                    _card(
                      8,
                      'Last Known Direction / Destination',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tf(
                            'Last Known Direction / Destination',
                            _lastKnown,
                            maxLines: 5,
                            onChanged: (v) => _onWordCapChanged(
                                _lastKnown, (n) => _lastKnownWords = n),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$_lastKnownWords / 25 words',
                              style: _tsMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('CCTV'),
                          const SizedBox(height: 12),
                          _kidYesNoToggle(
                            value: _cctvRecorded,
                            onChanged: (v) =>
                                setState(() => _cctvRecorded = v),
                          ),
                          const SizedBox(height: 12),
                          _kidAnimatedSwitch(
                            _cctvRecorded,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _kidResponsiveTwoFieldRow(
                                  context: context,
                                  first:
                                      _kidDateField('Date', _cctvDate),
                                  second:
                                      _kidTimeField('Time', _cctvTime),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _card(10, 'CDR Sent Date',
                        _slashDateRow('CDR Sent Date', _cdrSentDate)),
                    _card(
                      11,
                      'Outward Number & Date',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row([
                            _tf('Outward Number', _outwardNum),
                            StandardDatePicker(
                              label: 'Outward Date (dd/MM/yyyy)',
                              controller: _outwardDate,
                              lastDate: DateTime.now(),
                              onDateChanged: (_) => setState(() {}),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    _card(12, 'CDR Received Date',
                        _slashDateRow('CDR Received Date', _cdrReceivedDate)),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('Found Section'),
                          const SizedBox(height: 12),
                          _kidYesNoToggle(
                            value: _foundReported,
                            onChanged: (v) =>
                                setState(() => _foundReported = v),
                          ),
                          const SizedBox(height: 12),
                          _kidAnimatedSwitch(
                            _foundReported,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _kidResponsiveTwoFieldRow(
                                  context: context,
                                  first: _kidDateField(
                                      'Found Date', _foundDate),
                                  second: _kidTimeField(
                                      'Found Time', _foundTime),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _foundSd,
                                  style: GoogleFonts.poppins(),
                                  decoration: _kidInputDecoration(
                                      'SD Number / Station Diary Number'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _foundVillage,
                                  style: GoogleFonts.poppins(),
                                  decoration:
                                      _kidInputDecoration('Village / Town'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _foundAreaName,
                                  style: GoogleFonts.poppins(),
                                  decoration:
                                      _kidInputDecoration('Area Name'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _foundFullAddress,
                                  maxLines: 3,
                                  style: GoogleFonts.poppins(),
                                  decoration: _kidInputDecoration(
                                      'Full Address'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('Custody'),
                          const SizedBox(height: 12),
                          _custodyBlock(context),
                        ],
                      ),
                    ),
                    _card(
                      15,
                      'Remark',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tf(
                            'Remark',
                            _remark,
                            maxLines: 5,
                            onChanged: (v) => _onWordCapChanged(
                                _remark, (n) => _remarkWords = n),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$_remarkWords / 25 words',
                              style: _tsMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('164/183 Statement'),
                          const SizedBox(height: 12),
                          Text(
                            'Statement Recorded under 164/183?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kKidDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _kidYesNoToggle(
                            value: _statement164183Recorded,
                            onChanged: (v) => setState(
                                () => _statement164183Recorded = v),
                          ),
                          const SizedBox(height: 12),
                          _kidAnimatedSwitch(
                            _statement164183Recorded,
                            _kidResponsiveTwoFieldRow(
                              context: context,
                              first: _kidDateField(
                                  'Statement Date', _s164Date),
                              second: _kidTimeField(
                                  'Statement Time', _s164Time),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('CWC Statement'),
                          const SizedBox(height: 12),
                          Text(
                            'Statement Recorded before Child Welfare Committee (CWC)?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kKidDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _kidYesNoToggle(
                            value: _cwcRecorded,
                            onChanged: (v) =>
                                setState(() => _cwcRecorded = v),
                          ),
                          const SizedBox(height: 12),
                          _kidAnimatedSwitch(
                            _cwcRecorded,
                            _kidResponsiveTwoFieldRow(
                              context: context,
                              first: _kidDateField(
                                  'CWC Statement Date', _cwcDate),
                              second: _kidTimeField(
                                  'CWC Statement Time', _cwcTime),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('Medical Examination'),
                          const SizedBox(height: 12),
                          Text(
                            'Medical Examination Conducted?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kKidDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _kidYesNoToggle(
                            value: _medicalExamDone,
                            onChanged: (v) =>
                                setState(() => _medicalExamDone = v),
                          ),
                          const SizedBox(height: 12),
                          _kidAnimatedSwitch(
                            _medicalExamDone,
                            _kidResponsiveTwoFieldRow(
                              context: context,
                              first: _kidDateField(
                                  'Medical Examination Date',
                                  _medicalDate),
                              second: _kidTimeField(
                                  'Medical Examination Time',
                                  _medicalTime),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _kidSectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kidSectionTitle('In-Camera Statement'),
                          const SizedBox(height: 12),
                          Text(
                            'In-Camera Statement Recorded?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kKidDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _kidYesNoToggle(
                            value: _inCameraRecorded,
                            onChanged: (v) =>
                                setState(() => _inCameraRecorded = v),
                          ),
                          const SizedBox(height: 12),
                          _kidAnimatedSwitch(
                            _inCameraRecorded,
                            _kidResponsiveTwoFieldRow(
                              context: context,
                              first: _kidDateField(
                                  'In-Camera Statement Date',
                                  _inCameraDate),
                              second: _kidTimeField(
                                  'In-Camera Statement Time',
                                  _inCameraTime),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
