import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/inventory/application/inventory_notifier.dart';
import 'package:jewelry_ledger/features/inventory/presentation/add_product_sheet.dart';
import 'package:jewelry_ledger/shared/utils/currency_utils.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';
import 'package:jewelry_ledger/shared/widgets/status_badge.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.plus, color: isDark ? Colors.white : AppColors.primary),
            onPressed: () => showAddProductSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.cloudOff, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('Could not load inventory', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
              data: (items) {
                final filtered = items.where((i) => i.itemName.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.package, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No products yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first product', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    final status = item.stockStatus;
                    final statusColor = status == 'Out of Stock' ? AppColors.error : status == 'Low Stock' ? AppColors.warning : AppColors.success;
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            height: 48, width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(LucideIcons.package, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.itemName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
                                Text('${item.category ?? 'Uncategorized'} · ${CurrencyUtils.format(item.costPrice)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    StatusBadge(label: status, color: statusColor),
                                    const SizedBox(width: 8),
                                    Text(CurrencyUtils.format(item.totalValue), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${item.quantity}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
                              const Text('units', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
