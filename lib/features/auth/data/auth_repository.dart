import 'package:jewelry_ledger/core/utils/hash_utils.dart';
import 'package:jewelry_ledger/features/auth/domain/auth_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<AuthProfile?> getAccountByPhone(String phone) async {
    final normalizedPhone = HashUtils.normalizePhone(phone);
    
    try {
      final response = await _client
          .from('employees')
          .select()
          .eq('phone', normalizedPhone)
          .maybeSingle();

      if (response == null) return null;
      return AuthProfile.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  Future<String> signInWithPhonePin(String phone, String pin) async {
    final normalizedPhone = HashUtils.normalizePhone(phone);
    
    try {
      final response = await _client
          .from('employees')
          .select()
          .eq('phone', normalizedPhone)
          .maybeSingle();

      if (response == null) return 'not_found';

      final account = AuthProfile.fromMap(response);
      if (!account.isActive) return 'inactive';

      final expectedHash = response['pin_hash'];
      final actualHash = HashUtils.hashPin(pin, normalizedPhone);

      if (expectedHash != actualHash) return 'wrong';

      return 'success';
    } catch (e) {
      return 'error';
    }
  }

  Future<Map<String, dynamic>> signUpOwner({
    required String displayName,
    required String phone,
    required String pin,
    required String businessName,
  }) async {
    final normalizedPhone = HashUtils.normalizePhone(phone);
    final pinHash = HashUtils.hashPin(pin, normalizedPhone);

    try {
      final payload = {
        'display_name': displayName,
        'phone': normalizedPhone,
        'pin_hash': pinHash,
        'business_name': businessName,
        'created_by': normalizedPhone,
        'role': 'owner',
        'is_active': true,
      };

      final response = await _client
          .from('employees')
          .insert(payload)
          .select()
          .single();

      return {'ok': true, 'data': AuthProfile.fromMap(response)};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }
}
