import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/features/clients/data/client_repository.dart';
import 'package:jewelry_ledger/features/clients/domain/client.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(supabaseClientProvider));
});

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final auth = ref.watch(authProvider);
  final businessId = auth.profile?.id ?? '';
  if (businessId.isEmpty) return [];
  return ref.watch(clientRepositoryProvider).fetchAll(businessId);
});
