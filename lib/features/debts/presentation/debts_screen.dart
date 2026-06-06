import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/debts/application/debt_notifier.dart';
import 'package:jewelry_ledger/features/debts/domain/customer_ledger.dart';
import 'package:jewelry_ledger/shared/utils/currency_utils.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsState = ref.watch(debtsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Debts & Clients')),
      body: debtsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (ledgers) {
          final totalUnpaid = ledgers.fold<double>(0, (s, l) => s + l.totalDebt);

          return RefreshIndicator(
            onRefresh: () => ref.read(debtsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.users, color: AppColors.error, size: 24),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL OUTSTANDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(CurrencyUtils.format(totalUnpaid), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                          Text('Across ${ledgers.length} active clients', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Client Ledgers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 16),
                ...ledgers.map((l) => _CustomerRow(ledger: l, isDark: isDark)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final CustomerLedger ledger;
  final bool isDark;
  const _CustomerRow({required this.ledger, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(ledger.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ledger.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
                Text(ledger.phone ?? 'No phone', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyUtils.format(ledger.totalDebt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.error)),
              const Icon(LucideIcons.chevronRight, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
