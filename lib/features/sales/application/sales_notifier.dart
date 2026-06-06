import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/features/sales/data/sales_repository.dart';
import 'package:jewelry_ledger/features/sales/domain/sale_item.dart';
import 'package:jewelry_ledger/features/sales/domain/daily_report.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SalesRepository(client);
});

class SalesNotifier extends StateNotifier<AsyncValue<List<DailyReport>>> {
  final SalesRepository _repository;

  SalesNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final sales = await _repository.fetchAllSales();
      final debtStats = await _repository.fetchDebtStats();

      // Aggregate into DailyReports
      final Map<String, List<SaleItem>> dailyMap = {};
      for (var sale in sales) {
        final dateKey = sale.createdAt.toIso8601String().split('T')[0];
        dailyMap.putIfAbsent(dateKey, () => []).add(sale);
      }

      final List<DailyReport> reports = [];
      dailyMap.forEach((dateKey, items) {
        final date = DateTime.parse(dateKey);
        final salesTotal = items.fold<double>(0, (sum, item) => sum + item.totalRevenue);
        
        final debtsPaid = debtStats['daily_customer_payments_$dateKey'] ?? 0;
        final newDebt = debtStats['daily_new_debt_$dateKey'] ?? 0;
        final unpaidDebt = (newDebt - debtsPaid).clamp(0, double.infinity);

        reports.add(DailyReport(
          date: date,
          salesTotal: salesTotal,
          debtsPaid: debtsPaid,
          unpaidDebt: unpaidDebt.toDouble(),
          sales: items,
        ));
      });

      reports.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, AsyncValue<List<DailyReport>>>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return SalesNotifier(repository);
});
