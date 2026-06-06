import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/features/inventory/application/inventory_notifier.dart';
import 'package:jewelry_ledger/shared/widgets/app_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showAddProductSheet(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
  final catCtrl = TextEditingController();

  return showAppSheet(context, title: 'Add Product', child: Column(
    children: [
      sheetTextField(controller: nameCtrl, hint: 'Product Name', icon: LucideIcons.package),
      sheetTextField(controller: catCtrl, hint: 'Category (optional)', icon: LucideIcons.tag),
      sheetTextField(controller: qtyCtrl, hint: 'Quantity', icon: LucideIcons.hash, keyboardType: TextInputType.number),
      sheetTextField(controller: priceCtrl, hint: 'Cost Price', icon: LucideIcons.dollarSign, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      sheetButton(label: 'Add Product', onPressed: () async {
        if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
        final repo = ref.read(inventoryRepositoryProvider);
        final businessId = ref.read(authProvider).profile?.id ?? '';
        await repo.addProduct({
          'item_name': nameCtrl.text,
          'quantity': int.tryParse(qtyCtrl.text) ?? 1,
          'cost_price': double.tryParse(priceCtrl.text) ?? 0,
          'category': catCtrl.text.isEmpty ? null : catCtrl.text,
          'business_id': businessId,
        });
        ref.invalidate(inventoryProvider);
        if (context.mounted) Navigator.pop(context);
      }),
    ],
  ));
}
