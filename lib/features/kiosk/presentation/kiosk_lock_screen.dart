import 'package:flutter/material.dart';
import 'package:jewelry_ledger/core/kiosk_manager.dart';
import 'package:jewelry_ledger/shared/widgets/num_pad.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class KioskLockScreen extends StatefulWidget {
  final bool isUnlockOnly;
  const KioskLockScreen({super.key, this.isUnlockOnly = false});

  @override
  State<KioskLockScreen> createState() => _KioskLockScreenState();
}

class _KioskLockScreenState extends State<KioskLockScreen> {
  String _pin = '';
  String? _error;

  void _onDigit(String digit) {
    if (_pin.length >= 6) return;
    setState(() { _pin += digit; _error = null; });
    if (_pin.length == 6) _verify();
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    final ok = await KioskManager.instance.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      KioskManager.instance.unlock();
      Navigator.of(context).pop(true);
    } else {
      setState(() { _pin = ''; _error = 'Wrong PIN'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A5F), Color(0xFF0F1B2D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(height: 80, width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(LucideIcons.shield, color: Colors.white70, size: 40),
                ),
                const SizedBox(height: 24),
                Text(widget.isUnlockOnly ? 'Enter Admin PIN' : 'Kiosk Locked',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.isUnlockOnly ? 'Enter PIN to access settings' : 'Enter admin PIN to exit',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                const SizedBox(height: 40),
                if (_error != null)
                  Padding(padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 14))),
                SizedBox(
                  width: 360,
                  child: NumPad(
                    pinLength: 6, currentPin: _pin,
                    onDigitPress: _onDigit, onDeletePress: _onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
