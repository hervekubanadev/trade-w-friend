import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/sales/application/sales_notifier.dart';
import 'package:jewelry_ledger/features/sales/domain/daily_report.dart';
import 'package:jewelry_ledger/shared/utils/currency_utils.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(salesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Reports')),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reports) {
          final totalSales = reports.fold<double>(0, (s, r) => s + r.salesTotal);
          final totalDebt = reports.fold<double>(0, (s, r) => s + r.unpaidDebt);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Revenue', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                    const SizedBox(height: 4),
                    Text(CurrencyUtils.format(totalSales), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _miniStat('Received', CurrencyUtils.format(totalSales - totalDebt), Colors.greenAccent),
                        const SizedBox(width: 24),
                        _miniStat('Unpaid', CurrencyUtils.format(totalDebt), Colors.orangeAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('7-Day Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: _buildChartData(reports),
                    barTouchData: BarTouchData(enabled: false),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text('Daily Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 16),
              for (final report in reports) ...[
                GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(report.date.toString().split(' ')[0], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary)),
                          const Spacer(),
                          Text(CurrencyUtils.format(report.salesTotal), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _chip('Sales', CurrencyUtils.format(report.salesTotal), AppColors.success),
                          const SizedBox(width: 8),
                          if (report.unpaidDebt > 0) _chip('Unpaid', CurrencyUtils.format(report.unpaidDebt), AppColors.error),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 10, color: color)),
          Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildChartData(List<DailyReport> reports) {
    final recent = reports.take(7).toList().reversed.toList();
    return recent.asMap().entries.map((e) {
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: e.value.salesTotal, color: AppColors.primary, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
      ]);
    }).toList();
  }
}
