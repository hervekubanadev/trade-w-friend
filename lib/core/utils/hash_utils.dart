import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtils {
  static String hashPin(String pin, String phone) {
    // Matches the React implementation: `${normalizePhone(phone)}:${pin}`
    final raw = '$phone:$pin';
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('250') && digits.length == 12) {
      return '0${digits.substring(3)}';
    }

    if (digits.length == 9 && digits.startsWith('7')) {
      return '0$digits';
    }

    return digits;
  }

  static bool isValidRwandaPhone(String value) {
    final phone = normalizePhone(value);
    return RegExp(r'^07[2389]\d{7}$').hasMatch(phone);
  }
}
