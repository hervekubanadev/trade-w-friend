import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/features/auth/data/auth_repository.dart';
import 'package:jewelry_ledger/features/auth/domain/auth_profile.dart';
import 'package:jewelry_ledger/core/providers.dart';

class AuthState {
  final AuthProfile? profile;
  final bool isLoading;
  final String? error;

  AuthState({this.profile, this.isLoading = false, this.error});

  AuthState copyWith({AuthProfile? profile, bool? isLoading, String? error}) {
    return AuthState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<String> signIn(String phone, String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.signInWithPhonePin(phone, pin);
    if (result == 'success') {
      final profile = await _repository.getAccountByPhone(phone);
      state = state.copyWith(profile: profile, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result);
    }
    return result;
  }

  Future<String> register({
    required String name,
    required String phone,
    required String pin,
    required String business,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.signUpOwner(
      displayName: name,
      phone: phone,
      pin: pin,
      businessName: business,
    );
    if (result['ok'] == true) {
      final profile = result['data'] as AuthProfile;
      state = state.copyWith(profile: profile, isLoading: false);
      return 'success';
    }
    state = state.copyWith(isLoading: false, error: 'Registration failed');
    return 'failed';
  }

  Future<void> logout() async {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
