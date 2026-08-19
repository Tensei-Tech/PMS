import 'dart:async';
import 'package:flutter/material.dart';
import '../services/officer_sos_service.dart';

/// Interactive Emergency SOS Dialog for Field Officers
class OfficerSosDialog extends StatefulWidget {
  final String officerName;
  final String sevaNumber;
  final String designation;
  final String stationName;
  final String contactNumber;

  const OfficerSosDialog({
    super.key,
    required this.officerName,
    required this.sevaNumber,
    required this.designation,
    required this.stationName,
    required this.contactNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required String officerName,
    required String sevaNumber,
    required String designation,
    required String stationName,
    required String contactNumber,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OfficerSosDialog(
        officerName: officerName,
        sevaNumber: sevaNumber,
        designation: designation,
        stationName: stationName,
        contactNumber: contactNumber,
      ),
    );
  }

  @override
  State<OfficerSosDialog> createState() => _OfficerSosDialogState();
}

class _OfficerSosDialogState extends State<OfficerSosDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _countdown = 3;
  Timer? _timer;
  bool _isTriggered = false;
  bool _isBroadcasting = false;
  String? _alertId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        t.cancel();
        _broadcastSos();
      }
    });
  }

  void _cancelSos() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  Future<void> _broadcastSos() async {
    _timer?.cancel();
    setState(() {
      _isBroadcasting = true;
      _isTriggered = true;
    });

    try {
      final alertId = await OfficerSosService().triggerEmergencySos(
        officerName: widget.officerName,
        sevaNumber: widget.sevaNumber,
        designation: widget.designation,
        stationName: widget.stationName,
        contactNumber: widget.contactNumber,
      );

      if (mounted) {
        setState(() {
          _isBroadcasting = false;
          _alertId = alertId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBroadcasting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to broadcast SOS: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.redAccent.shade400, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated SOS Pulse Beacon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(16 + (_pulseController.value * 8)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(alpha: 0.2 + (_pulseController.value * 0.3)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                _isTriggered ? '🚨 SOS BROADCAST ACTIVE' : 'EMERGENCY DISTRESS SOS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                _isTriggered
                    ? 'Control Room and Admin Console have been alerted with your live GPS location & Seva credentials.'
                    : 'Broadcasting emergency distress alert to Station Control Room in $_countdown seconds...',
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Officer Info Capsule
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Officer:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${widget.designation} ${widget.officerName}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Seva No / Station:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${widget.sevaNumber} • ${widget.stationName}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              if (!_isTriggered) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelSos,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('CANCEL (रद्द करा)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _broadcastSos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SEND NOW 🚨', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('ACKNOWLEDGE & CLOSE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
