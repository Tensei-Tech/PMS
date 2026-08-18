// lib/screens/case_form_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/module_registry.dart';
import '../modules/core/models/base_record.dart';

class CaseFormScreen extends StatefulWidget {
  final String categoryName;
  final ModuleRecord? existingCase;

  const CaseFormScreen({super.key, required this.categoryName, this.existingCase});

  @override
  State<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends State<CaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseNoCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _accusedCtrl = TextEditingController();
  final _complainantCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime _incidentDate = DateTime.now();
  String _priority = 'Medium';

  bool get isEdit => widget.existingCase != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final c = widget.existingCase!;
      _caseNoCtrl.text = c.caseNumber;
      _titleCtrl.text = c.title;
      _descCtrl.text = c.description;
      _accusedCtrl.text = c.accused;
      _complainantCtrl.text = c.complainant;
      _locationCtrl.text = c.location;
      _incidentDate = c.incidentDate;
      _priority = c.priority;
    }
  }

  @override
  void dispose() {
    _caseNoCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _accusedCtrl.dispose();
    _complainantCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navyDark, size: 20),
        ),
        title: Text(
          isEdit ? 'Edit ${widget.categoryName}' : '${widget.categoryName} Form',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                'ACTIVE',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 900 ? 800 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('General Information', Icons.info_outline_rounded),
                  _buildCard([
                    _buildTextField('Case / FIR Number', _caseNoCtrl, Icons.numbers_rounded, hint: 'e.g. FIR/2024/102'),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField('Subject / Case Title', _titleCtrl, Icons.title_rounded, hint: 'Short title of the incident'),
                    const SizedBox(height: AppSpacing.md),
                    _buildDatePicker(),
                  ]),
                  
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('Incident Details', Icons.location_on_outlined),
                  _buildCard([
                    _buildTextField('Location', _locationCtrl, Icons.map_rounded, hint: 'Place of occurrence'),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField('Description', _descCtrl, Icons.description_outlined, hint: 'Detailed explanation...', maxLines: 4),
                  ]),
    
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('Parties Involved', Icons.people_outline_rounded),
                  _buildCard([
                    _buildTextField('Complainant Name', _complainantCtrl, Icons.person_add_alt_rounded),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField('Accused Name / Description', _accusedCtrl, Icons.person_off_rounded, hint: 'Leave empty if unknown'),
                  ]),
    
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('Priority & Status', Icons.priority_high_rounded),
                  _buildCard([
                    _buildPriorityDropdown(),
                  ]),
    
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.goldPrimary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.lightSubText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.lightText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.lightSubText,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.goldPrimary),
            filled: true,
            fillColor: const Color(0xFFF8FAFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Incident Date',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _incidentDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _incidentDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.goldPrimary),
                const SizedBox(width: 12),
                Text(
                  '${_incidentDate.day}/${_incidentDate.month}/${_incidentDate.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.lightText,
                  ),
                ),
                const Spacer(),
                Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.lightSubText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Level',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _priority,
              isExpanded: true,
              dropdownColor: Colors.white,
              items: ['Low', 'Medium', 'High'].map((p) => DropdownMenuItem(
                value: p,
                child: Text(p, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.lightText)),
              )).toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyMid.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final auth = context.read<AuthProvider>();
            final provider = getProvider(context, widget.categoryName);
            final moduleKey = labelToModuleKey[widget.categoryName] ?? 'nc';

            final record = ModuleRecord(
              id: isEdit ? widget.existingCase!.id : DateTime.now().millisecondsSinceEpoch.toString(),
              moduleKey: isEdit ? widget.existingCase!.moduleKey : moduleKey,
              title: _titleCtrl.text,
              description: _descCtrl.text,
              caseNumber: _caseNoCtrl.text,
              complainant: _complainantCtrl.text,
              accused: _accusedCtrl.text,
              location: _locationCtrl.text,
              incidentDate: _incidentDate,
              priority: _priority,
              status: isEdit ? widget.existingCase!.status : 'Open',
              assignedOfficer: isEdit ? widget.existingCase!.assignedOfficer : auth.displayName,
              createdAt: isEdit ? widget.existingCase!.createdAt : DateTime.now(),
              // Added critical audit & isolation fields
              createdBy: isEdit && widget.existingCase!.createdBy.isNotEmpty
                  ? widget.existingCase!.createdBy
                  : auth.uid,
              assignedOfficerUid: isEdit && (widget.existingCase!.assignedOfficerUid ?? '').isNotEmpty
                  ? widget.existingCase!.assignedOfficerUid
                  : auth.uid,
              stationName: isEdit && widget.existingCase!.stationName.isNotEmpty
                  ? widget.existingCase!.stationName
                  : auth.stationName,
              extraFields: {
                if (isEdit && widget.existingCase != null)
                  ...widget.existingCase!.extraFields,
                'lastEditedByUid': auth.uid,
                'lastEditedByName': auth.displayName,
                'lastEditedByDesignation': auth.designation,
                'lastEditedAt': DateTime.now().toIso8601String(),
              },
            );

            if (isEdit) {
              provider.updateRecord(record);
            } else {
              provider.addRecord(record);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEdit ? 'Record Updated Successfully!' : '${widget.categoryName} Form Submitted Successfully!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppColors.successGreen,
              ),
            );
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: Text(
          isEdit ? 'Update Details' : 'Submit Application',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
