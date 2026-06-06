import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/shared/widgets/num_pad.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AuthStep { welcome, phone, pin, registerInfo, registerPin }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  AuthStep _step = AuthStep.welcome;
  String _phone = '';
  String _pin = '';
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  String _regPin = '';
  String _regConfirm = '';
  bool _confirmingPin = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _businessCtrl.dispose();
    _regPhoneCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _animateForward() {
    _animCtrl.reset();
    _animCtrl.forward();
  }

  void _onDigit(String digit) {
    if (_step == AuthStep.registerPin) {
      if (!_confirmingPin) {
        if (_regPin.length < 6) setState(() => _regPin += digit);
        if (_regPin.length == 6) setState(() => _confirmingPin = true);
      } else {
        if (_regConfirm.length < 6) setState(() => _regConfirm += digit);
        if (_regConfirm.length == 6) _finishReg();
      }
      return;
    }
    if (_pin.length < 6) setState(() => _pin += digit);
    if (_pin.length == 6) _login();
  }

  void _onDelete() {
    if (_step == AuthStep.registerPin) {
      if (_confirmingPin && _regConfirm.isNotEmpty) {
        setState(() => _regConfirm = _regConfirm.substring(0, _regConfirm.length - 1));
      } else if (_confirmingPin && _regConfirm.isEmpty) {
        setState(() { _confirmingPin = false; _regPin = ''; });
      } else if (_regPin.isNotEmpty) {
        setState(() => _regPin = _regPin.substring(0, _regPin.length - 1));
      }
      return;
    }
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _login() async {
    final result = await ref.read(authProvider.notifier).signIn(_phone, _pin);
    if (!mounted) return;
    if (result == 'success') {
      context.go('/dashboard');
    } else {
      setState(() => _pin = '');
      _snack(result == 'not_found' ? 'Account not found' : result == 'wrong' ? 'Wrong PIN' : result == 'inactive' ? 'Account inactive' : 'Sign in failed. Check your connection.');
    }
  }

  Future<void> _finishReg() async {
    if (_regPin != _regConfirm) {
      setState(() { _regPin = ''; _regConfirm = ''; _confirmingPin = false; });
      _snack('PINs do not match');
      return;
    }
    final result = await ref.read(authProvider.notifier).register(
      name: _nameCtrl.text,
      phone: _regPhoneCtrl.text,
      pin: _regPin,
      business: _businessCtrl.text,
    );
    if (!mounted) return;
    if (result == 'success') {
      context.go('/dashboard');
    } else {
      _snack('Registration failed. Try again.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _go(AuthStep step) {
    setState(() => _step = step);
    _animateForward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFE8F0FE), const Color(0xFFF0F4FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Container(
                        height: 88, width: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(LucideIcons.store, color: AppColors.primary, size: 44),
                      ),
                      const SizedBox(height: 28),
                      Text('TradeWFriend+', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Text(_subtitle, style: GoogleFonts.inter(fontSize: 15, color: isDark ? Colors.grey.shade400 : AppColors.textTertiary)),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildStep(),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    switch (_step) {
      case AuthStep.welcome: return 'Business Management Platform';
      case AuthStep.phone: return 'Enter your phone to sign in';
      case AuthStep.pin: return _phone;
      case AuthStep.registerInfo: return 'Create your business account';
      case AuthStep.registerPin: return _confirmingPin ? 'Confirm PIN' : 'Set a 6-digit PIN';
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case AuthStep.welcome: return _welcome();
      case AuthStep.phone: return _phoneStep();
      case AuthStep.pin: return _pinStep();
      case AuthStep.registerInfo: return _registerInfo();
      case AuthStep.registerPin: return _registerPin();
    }
  }

  Widget _welcome() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _go(AuthStep.phone),
            icon: const Icon(LucideIcons.logIn, size: 20),
            label: const Text('Sign In'),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity, height: 54,
          child: OutlinedButton.icon(
            onPressed: () => _go(AuthStep.registerInfo),
            icon: const Icon(LucideIcons.userPlus, size: 20),
            label: const Text('Create Account'),
          ),
        ),
      ],
    );
  }

  Widget _phoneStep() {
    return Column(
      children: [
        TextField(
          controller: _phoneCtrl,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Phone Number', prefixIcon: Icon(LucideIcons.phone)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (_phoneCtrl.text.trim().isNotEmpty) {
                setState(() { _phone = _phoneCtrl.text.trim(); });
                _go(AuthStep.pin);
              }
            },
            child: const Text('Continue'),
          ),
        ),
        TextButton(onPressed: () => _go(AuthStep.welcome), child: Text('Back', style: TextStyle(color: Colors.grey.shade500))),
      ],
    );
  }

  Widget _pinStep() {
    final authState = ref.watch(authProvider);
    return Column(
      children: [
        SizedBox(
          width: 320,
          child: NumPad(
            pinLength: 6, currentPin: _pin,
            isLoading: authState.isLoading,
            onDigitPress: _onDigit, onDeletePress: _onDelete,
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => _go(AuthStep.phone),
          child: Text('Use different account', style: TextStyle(color: Colors.grey.shade500)),
        ),
      ],
    );
  }

  Widget _registerInfo() {
    return Column(
      children: [
        TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Your Name', prefixIcon: Icon(LucideIcons.user))),
        const SizedBox(height: 12),
        TextField(controller: _regPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone Number', prefixIcon: Icon(LucideIcons.phone))),
        const SizedBox(height: 12),
        TextField(controller: _businessCtrl, decoration: const InputDecoration(hintText: 'Business Name', prefixIcon: Icon(LucideIcons.building2))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isNotEmpty && _regPhoneCtrl.text.trim().isNotEmpty && _businessCtrl.text.trim().isNotEmpty) {
                _go(AuthStep.registerPin);
              }
            },
            child: const Text('Continue'),
          ),
        ),
        TextButton(onPressed: () => _go(AuthStep.welcome), child: Text('Back', style: TextStyle(color: Colors.grey.shade500))),
      ],
    );
  }

  Widget _registerPin() {
    final currentPin = _confirmingPin ? _regConfirm : _regPin;
    return Column(
      children: [
        SizedBox(
          width: 320,
          child: NumPad(
            pinLength: 6, currentPin: currentPin,
            onDigitPress: _onDigit, onDeletePress: _onDelete,
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => _go(AuthStep.registerInfo),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade500)),
        ),
      ],
    );
  }
}
