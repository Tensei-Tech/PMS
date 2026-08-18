import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../providers/settings_provider.dart';
import '../services/biometric_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'dashboard_screen.dart';

class EnableBiometricScreen extends StatefulWidget {
  const EnableBiometricScreen({super.key});

  @override
  State<EnableBiometricScreen> createState() => _EnableBiometricScreenState();
}

class _EnableBiometricScreenState extends State<EnableBiometricScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isFaceId = false;
  bool _hasTriggeredBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _isFaceId = available.contains(BiometricType.face);
      });
    }
  }

  Future<void> _handleContinue() async {
    if (_hasTriggeredBiometric) return;

    final hasEnrolled = await _biometricService.hasEnrolledBiometrics();
    
    if (!hasEnrolled) {
      if (!mounted) return;
      _showNotEnrolledDialog();
      return;
    }

    final reason = _isFaceId 
        ? 'Enable Face ID for faster login' 
        : 'Enable Fingerprint for faster login';
    
    if (mounted) {
      setState(() => _hasTriggeredBiometric = true);
    }

    final authenticated = await _biometricService.authenticate(localizedReason: reason);

    if (!authenticated && mounted) {
      setState(() => _hasTriggeredBiometric = false);
    }

    if (authenticated && mounted) {
      final settings = context.read<SettingsProvider>();
      await settings.setBiometricEnabled(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFaceId ? 'Face ID enabled successfully!' : 'Fingerprint enabled successfully!',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _navigateToHome();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed. Please try again.',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _showNotEnrolledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isFaceId ? 'Face ID Not Set Up' : 'Fingerprint Not Set Up',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          _isFaceId 
              ? 'Face ID not set up. Please go to Settings > Face ID & Passcode to enroll.'
              : 'No fingerprint found. Please add a fingerprint in Settings > Security to use this feature.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.lightSubText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (Platform.isAndroid) {
                await launchUrl(Uri.parse('package:com.android.settings'));
              } else {
                await launchUrl(Uri.parse('app-settings:'));
              }
            },
            child: Text('Open Settings', style: GoogleFonts.poppins(color: AppColors.navyMid, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      AppTheme.fadeSlideRoute(page: const DashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.navyMid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const AppLogo(size: 40),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isSmallScreen = availableHeight < 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 60),
                    Center(
                      child: Container(
                        width: isSmallScreen ? 140 : 180,
                        height: isSmallScreen ? 140 : 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withValues(alpha: 0.1),
                              primaryColor.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isFaceId ? Icons.face_rounded : Icons.fingerprint_rounded,
                            size: isSmallScreen ? 70 : 100,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 40),
                    Text(
                      _isFaceId ? 'Enable Face ID' : 'Enable Fingerprint',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isFaceId 
                          ? 'If you enable Face ID, you don\'t need to enter your password when you login.'
                          : 'If you enable touch ID, you don\'t need to enter your password when you login.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.lightSubText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 48),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
