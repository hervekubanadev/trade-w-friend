import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewelry_ledger/features/inventory/domain/inventory_item.dart';

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository(this._client);

  Future<List<InventoryItem>> fetchInventory() async {
    try {
      final response = await _client
          .from('inventory_items')
          .select()
          .order('item_name', ascending: true);
      return (response as List).map((m) => InventoryItem.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    await _client.from('inventory_items').update({'quantity': newQuantity}).eq('id', id);
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _client.from('inventory_items').insert(data);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('inventory_items').delete().eq('id', id);
  }
}
