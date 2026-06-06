import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/features/auth/data/auth_repository.dart';
import 'package:jewelry_ledger/features/auth/domain/auth_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final currentProfileProvider = StateProvider<AuthProfile?>((ref) => null);
