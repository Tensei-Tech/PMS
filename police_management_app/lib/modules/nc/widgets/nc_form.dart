// lib/modules/nc/widgets/nc_form.dart
// Standalone NC registration form — patterns duplicated from common_form.dart (unchanged source).

import 'package:flutter/material.dart';

import '../../../screens/ad_form_screen.dart' show ACT_DATA;
import '../../../utils/app_constants.dart';
import '../../../widgets/base_form/base_form.dart';
import '../../../widgets/voice_dictation_button.dart';

// ── Palette (matches common_form.dart) ───────────────────────────────────────
const Color _kDark = Color(0xFF0f172a);
const Color _kMid = Color(0xFF1e293b);
const Color _kTeal = Color(0xFF0ea5e9);
const Color _kGreen = Color(0xFF10b981);
const Color _kRed = Color(0xFFef4444);
const Color _kAmber = Color(0xFFf59e0b);
const Color _kSec = Color(0xFF64748b);
const Color _kMuted = Color(0xFF94a3b8);
const Color _kInputBg = Color(0xFFf8fafc);
const Color _kBorder = Color(0xFFe2e8f0);
const Color _kCardBg = Color(0xFFffffff);
const Color _kPageBg = Color(0xFFf4f7f9);

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
const _tsBody = TextStyle(fontSize: 12, color: _kDark);

const _kGenders = ['Male', 'Female', 'Other'];
const _kPreventiveItems = ['107 CrPC', '110 CrPC', 'MPDA', 'MCOCA'];

class NcForm extends StatefulWidget {
  const NcForm({super.key});

  @override
  State<NcForm> createState() => NcFormState();
}

class NcFormState extends State<NcForm> {
  late final ScrollController _scroll =
      ScrollController(); // mirrors CommonForm default scroll
  final ValueNotifier<double> scrollProgress = ValueNotifier(0);
  String saveBarText = 'All changes unsaved';

  final _ncNumber = TextEditingController();

  int _chargeSeq = 0;
  final Map<String, Map<String, dynamic>> _chargeData = {};

  final _regDateTime = TextEditingController();

  final _spotVillage = TextEditingController();
  final _spotArea = TextEditingController();
  final _spotAddress = TextEditingController();

  final _compName = TextEditingController();
  final _compAge = TextEditingController();
  String _compGender = 'Male';
  final _compOcc = TextEditingController();
  final _compMobile = TextEditingController();
  final _compAadhaar = TextEditingController();
  final _compPan = TextEditingController();
  final _compReligion = TextEditingController();
  final _compCaste = TextEditingController();

  final _againstName = TextEditingController();
  final _againstAge = TextEditingController();
  String _againstGender = 'Male';
  final _againstOcc = TextEditingController();
  final _againstMobile = TextEditingController();
  final _againstAadhaar = TextEditingController();
  final _againstPan = TextEditingController();
  final _againstReligion = TextEditingController();
  final _againstCaste = TextEditingController();

  String _ioDesig = 'PSI';
  final _ioName = TextEditingController();

  String _regDesig = 'HC';
  final _registrarName = TextEditingController();

  final List<_NcPreventiveRow> _preventives = [];

  final _caseOutwardNum = TextEditingController();
  final _caseOutwardDate = TextEditingController();

  final _fic = TextEditingController();
  int _ficWordCount = 0;

  String? _chargesAddedOnNc;
  final _crNumberIfCharges = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    scrollProgress.dispose();
    _ncNumber.dispose();
    _regDateTime.dispose();
    _spotVillage.dispose();
    _spotArea.dispose();
    _spotAddress.dispose();
    _compName.dispose();
    _compAge.dispose();
    _compOcc.dispose();
    _compMobile.dispose();
    _compAadhaar.dispose();
    _compPan.dispose();
    _compReligion.dispose();
    _compCaste.dispose();
    _againstName.dispose();
    _againstAge.dispose();
    _againstOcc.dispose();
    _againstMobile.dispose();
    _againstAadhaar.dispose();
    _againstPan.dispose();
    _againstReligion.dispose();
    _againstCaste.dispose();
    _ioName.dispose();
    _registrarName.dispose();
    for (final p in _preventives) {
      p.dispose();
    }
    _caseOutwardNum.dispose();
    _caseOutwardDate.dispose();
    _fic.dispose();
    _crNumberIfCharges.dispose();
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

  void saveDraft() {
    setState(() =>
        saveBarText = 'Draft saved · ${TimeOfDay.now().format(context)}');
  }

  void clearForm() {
    _ncNumber.clear();
    _chargeData.clear();
    _chargeSeq = 0;
    _regDateTime.clear();
    _spotVillage.clear();
    _spotArea.clear();
    _spotAddress.clear();
    _compName.clear();
    _compAge.clear();
    _compGender = 'Male';
    _compOcc.clear();
    _compMobile.clear();
    _compAadhaar.clear();
    _compPan.clear();
    _compReligion.clear();
    _compCaste.clear();
    _againstName.clear();
    _againstAge.clear();
    _againstGender = 'Male';
    _againstOcc.clear();
    _againstMobile.clear();
    _againstAadhaar.clear();
    _againstPan.clear();
    _againstReligion.clear();
    _againstCaste.clear();
    _ioDesig = 'PSI';
    _ioName.clear();
    _regDesig = 'HC';
    _registrarName.clear();
    for (final p in _preventives) {
      p.dispose();
    }
    _preventives.clear();
    _caseOutwardNum.clear();
    _caseOutwardDate.clear();
    _fic.clear();
    _ficWordCount = 0;
    _chargesAddedOnNc = null;
    _crNumberIfCharges.clear();
    saveBarText = 'All changes unsaved';
    setState(() {});
  }

  String _registeredDateDdMmYyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDateFor(
    TextEditingController ctrl, {
    DateTime? parsedFallback,
  }) async {
    final now = DateTime.now();
    DateTime initialDate() {
      final s = ctrl.text.trim();
      if (s.isEmpty) return parsedFallback ?? now;
      final p = s.split('/');
      if (p.length != 3) return parsedFallback ?? now;
      final d = int.tryParse(p[0]);
      final m = int.tryParse(p[1]);
      final y = int.tryParse(p[2]);
      if (d == null || m == null || y == null) return parsedFallback ?? now;
      final dt = DateTime(y, m, d);
      if (dt.year != y || dt.month != m || dt.day != d) return parsedFallback ?? now;
      if (dt.isBefore(DateTime(2000)) || dt.isAfter(now)) return parsedFallback ?? now;
      return dt;
    }

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: initialDate(),
    );
    if (!mounted || picked == null) return;
    setState(() {
      ctrl.text = _registeredDateDdMmYyyy(picked);
    });
  }

  String _formatRegDdMmYyyyHhMm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  DateTime? _parseRegDdMmYyyyHhMm(String raw) {
    final s = raw.trim();
    final m =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})\s+(\d{1,2}):(\d{2})$').firstMatch(s);
    if (m == null) return null;
    final dd = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    final yy = int.tryParse(m.group(3)!);
    final hh = int.tryParse(m.group(4)!);
    final mm = int.tryParse(m.group(5)!);
    if (dd == null || mo == null || yy == null || hh == null || mm == null) {
      return null;
    }
    if (hh > 23 || mm > 59) return null;
    try {
      final dt = DateTime(yy, mo, dd, hh, mm);
      if (dt.year != yy || dt.month != mo || dt.day != dd) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickRegistrationDateTime() async {
    final now = DateTime.now();
    final parsedExisting = _parseRegDdMmYyyyHhMm(_regDateTime.text);

    DateTime initialDateDay() {
      if (parsedExisting != null) {
        final dt = parsedExisting;
        if (!dt.isBefore(DateTime(2000)) && !dt.isAfter(now)) return dt;
      }
      return now;
    }

    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: initialDateDay(),
    );
    if (!mounted || pickedDate == null) return;

    final p0 = _parseRegDdMmYyyyHhMm(_regDateTime.text);
    final initialTod = p0 != null &&
            p0.year == pickedDate.year &&
            p0.month == pickedDate.month &&
            p0.day == pickedDate.day
        ? TimeOfDay(hour: p0.hour, minute: p0.minute)
        : TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTod,
    );
    if (!mounted || pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _regDateTime.text = _formatRegDdMmYyyyHhMm(combined);
    });
  }

  void addChargeRow() {
    _chargeSeq++;
    _chargeData['charge-$_chargeSeq'] = {
      'act': '',
      'sections': <String>{},
    };
    setState(() {});
  }

  void _removeCharge(String id) {
    _chargeData.remove(id);
    setState(() {});
  }

  void _onActChange(String id, String act) {
    _chargeData[id]!['act'] = act;
    _chargeData[id]!['sections'] = <String>{};
    setState(() {});
  }

  void _addSection(String id, String val) {
    (_chargeData[id]!['sections'] as Set<String>).add(val);
    setState(() {});
  }

  void _removeSection(String id, String val) {
    (_chargeData[id]!['sections'] as Set<String>).remove(val);
    setState(() {});
  }

  void addPreventiveRow() {
    setState(() => _preventives.add(_NcPreventiveRow()));
  }

  void _removePreventive(int i) {
    final r = _preventives.removeAt(i);
    r.dispose();
    setState(() {});
  }

  Map<String, dynamic> _personMap({
    required TextEditingController name,
    required TextEditingController age,
    required String gender,
    required TextEditingController occ,
    required TextEditingController mobile,
    required TextEditingController aadhaar,
    required TextEditingController pan,
    required TextEditingController religion,
    required TextEditingController caste,
  }) {
    return {
      'name': name.text.trim(),
      'age': age.text.trim(),
      'gender': gender,
      'occ': occ.text.trim(),
      'mobile': mobile.text.trim(),
      'aadhaar': aadhaar.text.trim(),
      'pan': pan.text.trim(),
      'religion': religion.text.trim(),
      'caste': caste.text.trim(),
    };
  }

  void _applyPersonMap(
    Map<String, dynamic> m, {
    required TextEditingController name,
    required TextEditingController age,
    required void Function(String) setGender,
    required TextEditingController occ,
    required TextEditingController mobile,
    required TextEditingController aadhaar,
    required TextEditingController pan,
    required TextEditingController religion,
    required TextEditingController caste,
  }) {
    name.text = _s(m['name']);
    age.text = _s(m['age']);
    final g = m['gender']?.toString();
    if (g != null && _kGenders.contains(g)) setGender(g);
    occ.text = _s(m['occ']);
    mobile.text = _s(m['mobile']);
    aadhaar.text = _s(m['aadhaar']);
    pan.text = _s(m['pan']);
    religion.text = _s(m['religion']);
    caste.text = _s(m['caste']);
  }

  String _s(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  /// Hydrates widgets from [extraFields['ncForm']] map.
  void hydrateFromNcMap(Map<String, dynamic> m) {
    clearForm();
    _ncNumber.text = _s(m['ncNumber']);
    final ch = m['charges'];
    if (ch is Map) {
      for (final e in ch.entries) {
        _chargeSeq++;
        final id = 'charge-$_chargeSeq';
        final raw = e.value as Map?;
        if (raw == null) continue;
        final secs = raw['sections'];
        _chargeData[id] = {
          'act': _s(raw['act']),
          'sections': <String>{
            if (secs is Iterable) for (final s in secs) s.toString(),
          },
        };
      }
    }
    _regDateTime.text = _s(m['registrationDateTime']);
    final spot = m['crimeSpot'];
    if (spot is Map) {
      _spotVillage.text = _s(spot['village']);
      _spotArea.text = _s(spot['area']);
      _spotAddress.text = _s(spot['address']);
    }
    final comp = m['complainant'];
    if (comp is Map) {
      _applyPersonMap(
        Map<String, dynamic>.from(comp),
        name: _compName,
        age: _compAge,
        setGender: (g) => _compGender = g,
        occ: _compOcc,
        mobile: _compMobile,
        aadhaar: _compAadhaar,
        pan: _compPan,
        religion: _compReligion,
        caste: _compCaste,
      );
    }
    final against = m['personComplainedAgainst'];
    if (against is Map) {
      _applyPersonMap(
        Map<String, dynamic>.from(against),
        name: _againstName,
        age: _againstAge,
        setGender: (g) => _againstGender = g,
        occ: _againstOcc,
        mobile: _againstMobile,
        aadhaar: _againstAadhaar,
        pan: _againstPan,
        religion: _againstReligion,
        caste: _againstCaste,
      );
    }
    final io = m['investigationOfficer'];
    if (io is Map) {
      final d = _s(io['designation']);
      if (d.isNotEmpty && PoliceDesignations.formIoAndReg.contains(d)) _ioDesig = d;
      _ioName.text = _s(io['name']);
    }
    final rb = m['registeredBy'];
    if (rb is Map) {
      final d = _s(rb['designation']);
      if (d.isNotEmpty && PoliceDesignations.formIoAndReg.contains(d)) _regDesig = d;
      _registrarName.text = _s(rb['name']);
    }
    final prev = m['preventives'];
    if (prev is List) {
      for (final raw in prev) {
        if (raw is! Map) continue;
        final row = _NcPreventiveRow();
        final act = raw['action']?.toString();
        if (act != null && _kPreventiveItems.contains(act)) {
          row.action = act;
        }
        row.outwardNum.text = _s(raw['outwardNumber']);
        row.outwardDate.text = _s(raw['outwardDate']);
        row.bondDate.text = _s(raw['bondDate']);
        row.bondCancel.text = _s(raw['bondCancellation']);
        _preventives.add(row);
      }
    }
    final ow = m['caseOutward'];
    if (ow is Map) {
      _caseOutwardNum.text = _s(ow['number']);
      _caseOutwardDate.text = _s(ow['date']);
    }
    _fic.text = _s(m['firstInformationContent']);
    _recountFicWords();
    final ca = m['chargesAddedOnNc']?.toString();
    if (ca == 'yes' || ca == 'no') _chargesAddedOnNc = ca;
    _crNumberIfCharges.text = _s(m['crNumberIfChargesAdded']);
    saveBarText = 'Loaded from record';
    setState(() {});
  }

  Map<String, dynamic> buildDocumentMap() {
    List<Map<String, dynamic>> preventiveMaps() => _preventives
        .map((p) => {
              'action': p.action,
              'outwardNumber': p.outwardNum.text.trim(),
              'outwardDate': p.outwardDate.text.trim(),
              'bondDate': p.bondDate.text.trim(),
              'bondCancellation': p.bondCancel.text.trim(),
            })
        .toList();

    return {
      'ncNumber': _ncNumber.text.trim(),
      'charges': _chargeData.map((k, v) => MapEntry(k, {
            'act': v['act'],
            'sections': (v['sections'] as Set<String>).toList(),
          })),
      'registrationDateTime': _regDateTime.text.trim(),
      'crimeSpot': {
        'village': _spotVillage.text.trim(),
        'area': _spotArea.text.trim(),
        'address': _spotAddress.text.trim(),
      },
      'complainant': _personMap(
        name: _compName,
        age: _compAge,
        gender: _compGender,
        occ: _compOcc,
        mobile: _compMobile,
        aadhaar: _compAadhaar,
        pan: _compPan,
        religion: _compReligion,
        caste: _compCaste,
      ),
      'personComplainedAgainst': _personMap(
        name: _againstName,
        age: _againstAge,
        gender: _againstGender,
        occ: _againstOcc,
        mobile: _againstMobile,
        aadhaar: _againstAadhaar,
        pan: _againstPan,
        religion: _againstReligion,
        caste: _againstCaste,
      ),
      'investigationOfficer': {
        'designation': _ioDesig,
        'name': _ioName.text.trim(),
      },
      'registeredBy': {
        'designation': _regDesig,
        'name': _registrarName.text.trim(),
      },
      'preventives': preventiveMaps(),
      'caseOutward': {
        'number': _caseOutwardNum.text.trim(),
        'date': _caseOutwardDate.text.trim(),
      },
      'firstInformationContent': _fic.text.trim(),
      'chargesAddedOnNc': _chargesAddedOnNc,
      'crNumberIfChargesAdded': _chargesAddedOnNc == 'yes'
          ? _crNumberIfCharges.text.trim()
          : '',
    };
  }

  void _onFicChanged(String v) {
    final words = v
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (words.length > 25) {
      final allowed = words.take(25).join(' ');
      _fic.value = TextEditingValue(
        text: allowed,
        selection: TextSelection.collapsed(offset: allowed.length),
      );
      setState(() => _ficWordCount = 25);
      return;
    }
    setState(() => _ficWordCount = words.length);
  }

  void _recountFicWords() {
    final words = _fic.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    _ficWordCount = words.length > 25 ? 25 : words.length;
  }

  InputDecoration _d(String label) => InputDecoration(
        labelText: label,
        labelStyle: _tsLabel,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        filled: true,
        fillColor: _kInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kTeal, width: 1.5),
        ),
      );

  Widget _row(List<Widget> children) =>
      StandardFormFieldRow(children: children);

  Widget _tf(
    String label,
    TextEditingController ctrl, {
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return StandardTextField(
      label: label,
      controller: ctrl,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      onChanged: onChanged,
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

  Widget _yesNo(String label, String? val, void Function(String) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _tsLabel),
        const SizedBox(height: 4),
        Row(
          children: [
            _yesNoChip('Yes', val == 'yes', _kGreen, () => onPick('yes')),
            const SizedBox(width: 6),
            _yesNoChip('No', val == 'no', _kRed, () => onPick('no')),
          ],
        ),
      ],
    );
  }

  Widget _yesNoChip(
      String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.1) : _kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? color : _kBorder, width: active ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? color : _kSec,
          ),
        ),
      ),
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

  Widget _card(int idx, String title, Widget body, {bool startOpen = false}) {
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

    final useExpansion = idx == 5 || idx == 6;
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

  Widget _chargeCard(String id, int num, Map<String, dynamic> data) {
    final actKey = data['act']?.toString() ?? '';
    final hasAct = actKey.isNotEmpty && ACT_DATA.containsKey(actKey);
    final secs = (data['sections'] as Set<String>?) ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Charge #$num',
                      style: _tsSection.copyWith(fontSize: 11))),
              GestureDetector(
                onTap: () => _removeCharge(id),
                child: const Icon(Icons.close, size: 16, color: _kRed),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _chipSelector(
            label: 'Act / Law',
            items:
                ACT_DATA.keys.map((k) => ACT_DATA[k]!['label'] as String).toList(),
            selected: hasAct ? (ACT_DATA[actKey]!['label'] as String) : null,
            onSelect: (label) {
              final key = ACT_DATA.entries
                  .firstWhere((e) => e.value['label'] == label)
                  .key;
              _onActChange(id, key);
            },
          ),
          if (hasAct) ...[
            const SizedBox(height: 4),
            Text(
              ACT_DATA[actKey]?['hint'] as String? ?? '',
              style: const TextStyle(
                  fontSize: 10, color: _kAmber, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text('Section(s) — tap to add', style: _tsLabel),
            const SizedBox(height: 4),
            _NcSectionSearchPicker(
              actKey: actKey,
              selected: secs,
              onAdd: (v) => _addSection(id, v),
              onRemove: (v) => _removeSection(id, v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sCharges() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _addBtn('+ Add Charge', addChargeRow),
          if (_chargeData.isEmpty)
            _emptyBox('No charges. Tap + Add Charge to begin.')
          else ...[
            ..._chargeData.entries.toList().asMap().entries.map((e) {
              final id = e.value.key;
              final data = e.value.value;
              final num = e.key + 1;
              return _chargeCard(id, num, data);
            }),
          ],
        ],
      );

  Widget _sRegDt() => Column(
        children: [
          _row([
            TextFormField(
              controller: _regDateTime,
              readOnly: true,
              style: _tsBody,
              decoration: _d('Registration Date & Time (dd/MM/yyyy HH:mm)')
                  .copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded,
                      size: 18, color: _kTeal),
                  tooltip: 'Pick date & time',
                  onPressed: _pickRegistrationDateTime,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minHeight: 32, minWidth: 36),
                ),
              ),
              onTap: () => _pickRegistrationDateTime(),
            ),
          ]),
        ],
      );

  Widget _sSpot() => Column(
        children: [
          _row([
            _tf('Village/Town', _spotVillage),
            _tf('Area Name', _spotArea),
          ]),
          _row([_tf('Full Address', _spotAddress, maxLines: 3)]),
        ],
      );

  Widget _sComplainant() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row([
            _tf('Name', _compName),
            _tf('Age', _compAge, keyboardType: TextInputType.number),
          ]),
          _row([
            _chipSelector(
              label: 'Gender',
              items: _kGenders,
              selected: _compGender,
              onSelect: (v) => setState(() => _compGender = v),
            ),
          ]),
          const SizedBox(height: 4),
          _row([
            _tf('Occupation', _compOcc),
            _tf('Mobile Number', _compMobile,
                keyboardType: TextInputType.phone),
          ]),
          _row([
            _tf('Aadhaar Number', _compAadhaar),
            _tf('PAN Number', _compPan),
          ]),
          _row([_tf('Religion', _compReligion), _tf('Caste', _compCaste)]),
        ],
      );

  Widget _sAgainst() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row([
            _tf('Name', _againstName),
            _tf('Age', _againstAge, keyboardType: TextInputType.number),
          ]),
          _row([
            _chipSelector(
              label: 'Gender',
              items: _kGenders,
              selected: _againstGender,
              onSelect: (v) => setState(() => _againstGender = v),
            ),
          ]),
          const SizedBox(height: 4),
          _row([
            _tf('Occupation', _againstOcc),
            _tf('Mobile Number', _againstMobile,
                keyboardType: TextInputType.phone),
          ]),
          _row([
            _tf('Aadhaar Number', _againstAadhaar),
            _tf('PAN Number', _againstPan),
          ]),
          _row([
            _tf('Religion', _againstReligion),
            _tf('Caste', _againstCaste),
          ]),
        ],
      );

  Widget _sIo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipSelector(
            label: 'IO Designation',
            items: PoliceDesignations.formIoAndReg,
            selected: _ioDesig,
            onSelect: (v) => setState(() => _ioDesig = v),
          ),
          const SizedBox(height: 8),
          _row([_tf('IO Name', _ioName)]),
        ],
      );

  Widget _sRegBy() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipSelector(
            label: 'Registered By Designation',
            items: PoliceDesignations.formIoAndReg,
            selected: _regDesig,
            onSelect: (v) => setState(() => _regDesig = v),
          ),
          const SizedBox(height: 8),
          _row([_tf('Registrar Name', _registrarName)]),
        ],
      );

  Widget _sPreventives() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _addBtn('+ Add Preventive', addPreventiveRow),
          if (_preventives.isEmpty)
            _emptyBox('No preventive blocks. Tap + Add Preventive.')
          else
            ..._preventives.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: _kBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Preventive #${i + 1}',
                              style: _tsSection.copyWith(fontSize: 11)),
                        ),
                        GestureDetector(
                          onTap: () => _removePreventive(i),
                          child:
                              const Icon(Icons.close, size: 16, color: _kRed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _chipSelector(
                      label: 'Preventive Action',
                      items: _kPreventiveItems,
                      selected: p.action,
                      onSelect: (v) => setState(() => p.action = v),
                    ),
                    const SizedBox(height: 8),
                    _row([_tf('Outward Number', p.outwardNum)]),
                    _row([
                      TextFormField(
                        controller: p.outwardDate,
                        readOnly: true,
                        style: _tsBody,
                        decoration:
                            _d('Outward Date (dd/MM/yyyy)').copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded,
                                size: 18, color: _kTeal),
                            tooltip: 'Pick date',
                            onPressed: () =>
                                _pickDateFor(p.outwardDate),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minHeight: 32, minWidth: 36),
                          ),
                        ),
                        onTap: () => _pickDateFor(p.outwardDate),
                      ),
                    ]),
                    _row([
                      TextFormField(
                        controller: p.bondDate,
                        readOnly: true,
                        style: _tsBody,
                        decoration: _d('Bond Date (dd/MM/yyyy)').copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded,
                                size: 18, color: _kTeal),
                            tooltip: 'Pick date',
                            onPressed: () => _pickDateFor(p.bondDate),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minHeight: 32, minWidth: 36),
                          ),
                        ),
                        onTap: () => _pickDateFor(p.bondDate),
                      ),
                      TextFormField(
                        controller: p.bondCancel,
                        readOnly: true,
                        style: _tsBody,
                        decoration:
                            _d('Bond Cancellation Date (dd/MM/yyyy)')
                                .copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded,
                                size: 18, color: _kTeal),
                            tooltip: 'Pick date',
                            onPressed: () =>
                                _pickDateFor(p.bondCancel),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minHeight: 32, minWidth: 36),
                          ),
                        ),
                        onTap: () => _pickDateFor(p.bondCancel),
                      ),
                    ]),
                  ],
                ),
              );
            }),
        ],
      );

  Widget _sCaseOutward() => Column(
        children: [
          _row([_tf('Outward Number', _caseOutwardNum)]),
          _row([
            TextFormField(
              controller: _caseOutwardDate,
              readOnly: true,
              style: _tsBody,
              decoration: _d('Outward Date (dd/MM/yyyy)').copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded,
                      size: 18, color: _kTeal),
                  tooltip: 'Pick date',
                  onPressed: () => _pickDateFor(_caseOutwardDate),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minHeight: 32, minWidth: 36),
                ),
              ),
              onTap: () => _pickDateFor(_caseOutwardDate),
            ),
          ]),
        ],
      );

  Widget _sFic() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('First Information Content / हकीकत', style: _tsLabel),
              VoiceDictationButton(
                controller: _fic,
                label: 'बोलून लिहा (Voice)',
                onSpeechCompleted: () => _onFicChanged(_fic.text),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _tf(
            '',
            _fic,
            maxLines: 5,
            onChanged: _onFicChanged,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$_ficWordCount / 25 words',
              style: _tsMuted,
            ),
          ),
        ],
      );

  Widget _sChargesAdded() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _yesNo('Charges Added on NC', _chargesAddedOnNc,
              (v) => setState(() => _chargesAddedOnNc = v)),
          if (_chargesAddedOnNc == 'yes') ...[
            const SizedBox(height: 8),
            _row([_tf('CR Number', _crNumberIfCharges)]),
          ],
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
              child: ListView(
                controller: _scroll,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                children: [
                  BaseFormContent.scrollSections(
                    children: [
                  _card(1, 'NC Number', _row([_tf('NC Number', _ncNumber)]),
                      startOpen: true),
                  _card(2, 'Acts & Sections', _sCharges(), startOpen: true),
                  _card(3, 'Registration Date & Time', _sRegDt(),
                      startOpen: true),
                  _card(4, 'Crime Spot', _sSpot()),
                  _card(5, 'Complainant KYC', _sComplainant()),
                  _card(6, 'Person Complained Against KYC', _sAgainst()),
                  _card(7, 'Investigation Officer', _sIo()),
                  _card(8, 'Registered By', _sRegBy()),
                  _card(9, 'Preventives', _sPreventives()),
                  _card(10, 'Outward Number & Date', _sCaseOutward()),
                  _card(11, 'First Information Content', _sFic()),
                  _card(12, 'Charges Added on NC', _sChargesAdded()),
                  const SizedBox(height: 80),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NcPreventiveRow {
  String? action;
  final outwardNum = TextEditingController();
  final outwardDate = TextEditingController();
  final bondDate = TextEditingController();
  final bondCancel = TextEditingController();

  void dispose() {
    outwardNum.dispose();
    outwardDate.dispose();
    bondDate.dispose();
    bondCancel.dispose();
  }
}

/// Duplicated from common_form.dart `_SectionSearchPicker` (same behaviour).
class _NcSectionSearchPicker extends StatefulWidget {
  const _NcSectionSearchPicker({
    required this.actKey,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });
  final String actKey;
  final Set<String> selected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  State<_NcSectionSearchPicker> createState() =>
      _NcSectionSearchPickerState();
}

class _NcSectionSearchPickerState extends State<_NcSectionSearchPicker> {
  final _ctrl = TextEditingController();
  String _query = '';
  bool _open = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections =
        (ACT_DATA[widget.actKey]?['sections'] as List<dynamic>? ?? [])
            .map((r) => r as Map<String, dynamic>)
            .toList();

    final filtered = _query.isEmpty
        ? sections
        : sections.where((s) {
            final lbl = (s['label'] as String? ?? '').toLowerCase();
            final val = (s['val'] as String? ?? '').toLowerCase();
            final q = _query.toLowerCase();
            return lbl.contains(q) || val.contains(q);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selected.isNotEmpty)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: widget.selected.map((v) {
              final sec = sections.firstWhere((s) => s['val'] == v,
                  orElse: () => {'val': v, 'label': v, 'cat': ''});
              return InputChip(
                label: Text(
                  '§${sec['val']}',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700),
                ),
                tooltip: sec['label'] as String? ?? v,
                onDeleted: () => widget.onRemove(v),
                deleteIconColor: _kSec,
                backgroundColor: _kTeal.withValues(alpha: 0.08),
                side: const BorderSide(color: _kTeal, width: 0.8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              );
            }).toList(),
          ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ctrl,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Search sections…',
            hintStyle: _tsMuted,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: _kInputBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kTeal, width: 1.5)),
            prefixIcon: const Icon(Icons.search, size: 15, color: _kSec),
          ),
          onChanged: (v) => setState(() {
            _query = v;
            _open = v.isNotEmpty;
          }),
          onTap: () => setState(() => _open = true),
        ),
        if (_open && filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: filtered.length.clamp(0, 50),
              itemBuilder: (_, i) {
                final s = filtered[i];
                final v = s['val'] as String;
                final isSelected = widget.selected.contains(v);
                return InkWell(
                  onTap: isSelected
                      ? null
                      : () {
                          widget.onAdd(v);
                          _ctrl.clear();
                          setState(() {
                            _query = '';
                            _open = false;
                          });
                        },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _kTeal.withValues(alpha: 0.07) : null,
                      border: Border(
                          bottom: BorderSide(color: _kBorder, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          margin: const EdgeInsets.only(right: 8),
                          child: Text(
                            '§$v',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? _kTeal : _kSec,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            s['label'] as String? ?? v,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? _kTeal : _kDark,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, size: 14, color: _kTeal),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
