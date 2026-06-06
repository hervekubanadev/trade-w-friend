import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jewelry_ledger/core/kiosk_manager.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/kiosk/presentation/kiosk_lock_screen.dart';
import 'package:jewelry_ledger/shared/widgets/num_pad.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class KioskSettingsScreen extends StatefulWidget {
  const KioskSettingsScreen({super.key});

  @override
  State<KioskSettingsScreen> createState() => _KioskSettingsScreenState();
}

class _KioskSettingsScreenState extends State<KioskSettingsScreen> {
  final _manager = KioskManager.instance;
  bool _kioskEnabled = false;
  bool _hasPin = false;
  bool _isLoading = true;
  bool _isSettingPin = false;
  String _newPin = '';
  String _confirmPin = '';
  String _step = '';
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _kioskEnabled = _manager.isEnabled;
    _hasPin = await _manager.hasPin();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleKiosk(bool value) async {
    if (value) {
      if (!_hasPin) { _startPinSetup(); return; }
      await _manager.enable();
    } else {
      final locked = await showDialog<bool>(
        context: context, barrierDismissible: false,
        builder: (_) => const KioskLockScreen(isUnlockOnly: true),
      );
      if (locked == true) await _manager.disable();
      else return;
    }
    setState(() => _kioskEnabled = _manager.isEnabled);
  }

  void _startPinSetup() {
    setState(() { _isSettingPin = true; _step = 'new'; _newPin = ''; _confirmPin = ''; _pinError = null; });
  }

  void _onSetupDigit(String digit) {
    if (_step == 'new') {
      if (_newPin.length >= 6) return;
      _newPin += digit; _pinError = null;
      if (_newPin.length == 6) setState(() => _step = 'confirm');
    } else {
      if (_confirmPin.length >= 6) return;
      _confirmPin += digit; _pinError = null;
      if (_confirmPin.length == 6) _finishSetup();
    }
  }

  void _onSetupDelete() {
    if (_step == 'confirm' && _confirmPin.isNotEmpty) {
      setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
    } else if (_step == 'confirm' && _confirmPin.isEmpty) {
      setState(() { _step = 'new'; _newPin = ''; });
    } else if (_newPin.isNotEmpty) {
      setState(() => _newPin = _newPin.substring(0, _newPin.length - 1));
    }
  }

  Future<void> _finishSetup() async {
    if (_newPin != _confirmPin) {
      setState(() { _pinError = 'PINs do not match'; _step = 'new'; _newPin = ''; _confirmPin = ''; });
      return;
    }
    await _manager.setPin(_newPin);
    await _manager.enable();
    setState(() { _isSettingPin = false; _hasPin = true; _kioskEnabled = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSettingPin) return _buildPinSetup();
    return Scaffold(
      appBar: AppBar(title: const Text('Kiosk Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kioskEnabled ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kioskEnabled ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kioskEnabled ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_kioskEnabled ? LucideIcons.shield : LucideIcons.shieldOff,
                        color: _kioskEnabled ? AppColors.primary : Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kiosk Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_kioskEnabled ? 'Full-screen, PIN-protected' : 'Tap to enable',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _kioskEnabled, onChanged: _isLoading ? null : _toggleKiosk,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
                if (_kioskEnabled) ...[
                  const Divider(height: 24),
                  Row(children: [
                    const Icon(LucideIcons.info, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Back button requires admin PIN · Full-screen mode',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_hasPin) ...[
            _option(icon: LucideIcons.keyRound, title: 'Change Admin PIN', subtitle: 'Update your 6-digit kiosk PIN', onTap: _startPinSetup),
            const SizedBox(height: 12),
            _option(icon: LucideIcons.refreshCw, title: 'Reset Kiosk Settings', subtitle: 'Disable kiosk and clear PIN', onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Kiosk?'),
                  content: const Text('This will disable kiosk mode and clear the admin PIN.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await _manager.disable();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('kiosk_admin_pin_hash');
                setState(() { _kioskEnabled = false; _hasPin = false; });
              }
            }, destructive: true),
          ],
        ],
      ),
    );
  }

  Widget _option({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool destructive = false}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: destructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: destructive ? AppColors.error : AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          )),
          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildPinSetup() {
    final currentPin = _step == 'new' ? _newPin : _confirmPin;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A5F), Color(0xFF0F1B2D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SizedBox(height: 60),
              Container(height: 80, width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(LucideIcons.keyRound, color: Colors.white70, size: 40),
              ),
              const SizedBox(height: 24),
              Text(_step == 'new' ? 'Set Admin PIN' : 'Confirm PIN',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_step == 'new' ? 'Enter a 6-digit PIN' : 'Enter the same PIN again',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
              const SizedBox(height: 40),
              if (_pinError != null)
                Padding(padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_pinError!, style: const TextStyle(color: Colors.redAccent, fontSize: 14))),
              SizedBox(
                width: 360,
                child: NumPad(
                  pinLength: 6, currentPin: currentPin,
                  onDigitPress: _onSetupDigit, onDeletePress: _onSetupDelete,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
