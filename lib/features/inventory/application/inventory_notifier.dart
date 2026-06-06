import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/features/inventory/data/inventory_repository.dart';
import 'package:jewelry_ledger/features/inventory/domain/inventory_item.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(supabaseClientProvider));
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  final InventoryRepository _repository;

  InventoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.fetchInventory();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryItem>>>((ref) {
  return InventoryNotifier(ref.watch(inventoryRepositoryProvider));
});
