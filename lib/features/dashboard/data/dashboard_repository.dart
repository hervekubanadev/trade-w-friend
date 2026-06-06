import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewelry_ledger/features/dashboard/domain/dashboard_stats.dart';

class DashboardRepository {
  final SupabaseClient _client;

  DashboardRepository(this._client);

  Future<DashboardStats> fetchStats() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      final responses = await Future.wait([
        _client.from('sales').select('sale_price, quantity, created_at'),
        _client.from('customers').select('id'),
        // Note: The React app mentions 'debt_items' and 'debt_payments' 
        // but the types.ts shows 'customers' as having 'amount' and 'is_paid'.
        // I'll stick to the database schema found in types.ts for now.
        _client.from('customers').select('amount, is_paid, created_at'),
        _client.from('inventory_items').select('quantity, cost_price'),
      ]);

      final sales = responses[0] as List;
      final customersCount = (responses[1] as List).length;
      final debts = responses[2] as List;
      final inventory = responses[3] as List;

      double totalCashSales = 0;
      double todayCashSales = 0;
      for (var s in sales) {
        final price = (s['sale_price'] as num).toDouble();
        totalCashSales += price;
        if (s['created_at'].toString().startsWith(today)) {
          todayCashSales += price;
        }
      }

      double totalDebt = 0;
      for (var d in debts) {
        if (d['is_paid'] == false) {
          totalDebt += (d['amount'] as num).toDouble();
        }
      }

      double inventoryValue = 0;
      for (var i in inventory) {
        inventoryValue += (i['quantity'] as num).toDouble() * (i['cost_price'] as num).toDouble();
      }

      return DashboardStats(
        totalRevenue: totalCashSales, // In the simple model, revenue = cash sales
        totalDebt: totalDebt,
        inventoryValue: inventoryValue,
        todayRevenue: todayCashSales,
        totalCustomers: customersCount,
        totalProducts: inventory.length,
      );
    } catch (_) {
      return DashboardStats();
    }
  }
}
