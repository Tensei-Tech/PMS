// lib/utils/pdf_auth_gate.dart
// PDF export PIN gate — coordinates with PoliceMgmtApp resume biometric (main.dart).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// While **true**, the app resume-handler must **not** stack another biometric overlay
/// (see [PoliceMgmtApp] in `main.dart`). **Idle value is false.**
bool isPdfDownloadAuthGateActive = false;

Future<void> runWithPdfAuthGate(
  BuildContext context,
  Future<void> Function() action,
) async {
  if (!context.mounted) return;

  final auth = context.read<AuthProvider>();

  isPdfDownloadAuthGateActive = true;
  try {
    final ok = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => _PdfExportPinDialog(auth: auth),
        ) ??
        false;

    if (!ok || !context.mounted) return;

    await action();
  } finally {
    isPdfDownloadAuthGateActive = false;
  }
}

class _PdfExportPinDialog extends StatefulWidget {
  const _PdfExportPinDialog({required this.auth});

  final AuthProvider auth;

  @override
  State<_PdfExportPinDialog> createState() => _PdfExportPinDialogState();
}

class _PdfExportPinDialogState extends State<_PdfExportPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pinCtrl = TextEditingController();
  bool _verifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  /// Same rules as [PinReauthScreen] (validation only; verification is [AuthProvider.verifyPin]).
  String? _validate(String? v) {
    if (v == null || v.isEmpty) return 'PIN is required';
    if (v.length < 4 || v.length > 6) return 'PIN must be 4-6 digits';
    if (!RegExp(r'^\d{4,6}$').hasMatch(v)) return 'PIN must contain only digits';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _verifying = true;
      _errorMessage = null;
    });

    final pin = _pinCtrl.text.trim();
    final ok = await widget.auth.verifyPin(pin);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _verifying = false;
      _errorMessage = 'Incorrect PIN. Please try again.';
      _pinCtrl.clear();
    });
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        'PIN required',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: AppColors.navyDark,
          fontSize: 17,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your PIN to download / export PDF.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.lightSubText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  hintText: '●●●●',
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.navyMid),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  errorText: _errorMessage,
                ),
                validator: _validate,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _verifying ? null : _cancel,
          child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.lightSubText)),
        ),
        ElevatedButton(
          onPressed: _verifying ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navyMid,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
          ),
          child: _verifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text('Verify', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
