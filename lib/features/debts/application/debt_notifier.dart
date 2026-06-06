import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/features/debts/data/debt_repository.dart';
import 'package:jewelry_ledger/features/debts/domain/customer_ledger.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DebtRepository(client);
});

class DebtNotifier extends StateNotifier<AsyncValue<List<CustomerLedger>>> {
  final DebtRepository _repository;

  DebtNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.fetchLedgers();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordPayment(String id, double amount) async {
    try {
      await _repository.recordPayment(id, amount);
      refresh();
    } catch (e) {
      // Handle error
    }
  }
}

final debtsProvider = StateNotifierProvider<DebtNotifier, AsyncValue<List<CustomerLedger>>>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return DebtNotifier(repository);
});
