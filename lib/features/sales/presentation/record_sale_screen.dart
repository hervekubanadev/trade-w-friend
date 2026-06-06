import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/features/inventory/domain/inventory_item.dart';
import 'package:jewelry_ledger/features/inventory/application/inventory_notifier.dart';
import 'package:jewelry_ledger/features/sales/application/sales_notifier.dart';
import 'package:jewelry_ledger/features/sales/data/sales_repository.dart';
import 'package:jewelry_ledger/shared/utils/currency_utils.dart';
import 'package:jewelry_ledger/shared/widgets/app_bottom_sheet.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RecordSaleScreen extends ConsumerStatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  ConsumerState<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends ConsumerState<RecordSaleScreen> {
  InventoryItem? _selected;
  int _qty = 1;
  final _searchCtrl = TextEditingController();
  double _salePrice = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null || _qty <= 0) return;
    final repo = SalesRepository(ref.read(supabaseClientProvider));
    final businessId = ref.read(authProvider).profile?.id ?? '';
    await repo.addSale({
      'item_name': _selected!.itemName,
      'quantity': _qty,
      'sale_price': _salePrice > 0 ? _salePrice : _selected!.costPrice,
      'cost_price': _selected!.costPrice,
      'business_id': businessId,
    });
    ref.invalidate(salesProvider);
    ref.invalidate(inventoryProvider);
    if (mounted) Navigator.pop(context);
  }

  void _showQtyPicker() {
    final ctrl = TextEditingController(text: _qty.toString());
    showAppSheet(context, title: 'Select Quantity', heightFactor: 0.4, child: Column(
      children: [
        sheetTextField(controller: ctrl, hint: 'Quantity', icon: LucideIcons.hash, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        sheetButton(label: 'Done', onPressed: () {
          setState(() => _qty = int.tryParse(ctrl.text) ?? 1);
          Navigator.pop(context);
        }),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Sale')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Select Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (items) {
              final filtered = items.where((i) => i.itemName.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
              return SizedBox(
                height: 220,
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    final sel = _selected?.id == item.id;
                    return ListTile(
                      selected: sel,
                      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(item.itemName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
                      subtitle: Text('${item.quantity} in stock · ${CurrencyUtils.format(item.costPrice)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      trailing: sel ? const Icon(LucideIcons.checkCircle, color: AppColors.primary) : null,
                      onTap: () => setState(() { _selected = item; _salePrice = item.costPrice; }),
                    );
                  },
                ),
              );
            },
          ),
          if (_selected != null) ...[
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selected!.itemName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showQtyPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.hash, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          Text(CurrencyUtils.format(_salePrice * _qty), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Sale Price per unit', prefixIcon: Icon(LucideIcons.dollarSign)),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: _salePrice.toStringAsFixed(0)),
                    onChanged: (v) => setState(() => _salePrice = double.tryParse(v) ?? _salePrice),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(LucideIcons.receipt, size: 20),
                label: Text('Complete Sale — ${CurrencyUtils.format(_salePrice * _qty)}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
