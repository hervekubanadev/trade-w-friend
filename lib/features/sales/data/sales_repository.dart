import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewelry_ledger/features/sales/domain/sale_item.dart';

class SalesRepository {
  final SupabaseClient _client;

  SalesRepository(this._client);

  Future<List<SaleItem>> fetchAllSales() async {
    try {
      final response = await _client
          .from('sales')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((m) => SaleItem.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, double>> fetchDebtStats() async {
    try {
      final response = await _client
          .from('app_settings')
          .select('setting_key, setting_value');
      final Map<String, double> stats = {};
      for (var row in response) {
        stats[row['setting_key']] = double.tryParse(row['setting_value'].toString()) ?? 0;
      }
      return stats;
    } catch (_) {
      return {};
    }
  }

  Future<void> addSale(Map<String, dynamic> data) async {
    await _client.from('sales').insert(data);
  }
}
