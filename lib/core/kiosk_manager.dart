import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class KioskManager {
  static const _pinKey = 'kiosk_admin_pin_hash';
  static const _enabledKey = 'kiosk_mode_enabled';

  static final KioskManager _instance = KioskManager._();
  static KioskManager get instance => _instance;
  KioskManager._();

  bool _enabled = false;
  bool _locked = false;

  bool get isEnabled => _enabled;
  bool get isLocked => _locked;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    if (_enabled) {
      await _activate();
    }
  }

  Future<void> _activate() async {
    _enabled = true;
    _locked = true;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pinKey);
    if (stored == null) return false;
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString() == stored;
  }

  Future<void> setPin(String pin) async {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, digest.toString());
  }

  Future<void> enable() async {
    await _activate();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
  }

  Future<void> disable() async {
    _enabled = false;
    _locked = false;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setPreferredOrientations([]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }

  void unlock() => _locked = false;
  void lock() => _locked = true;
}
