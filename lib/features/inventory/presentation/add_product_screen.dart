import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/features/inventory/application/inventory_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    final repo = ref.read(inventoryRepositoryProvider);
    final businessId = ref.read(authProvider).profile?.id ?? '';
    await repo.addProduct({
      'item_name': _nameCtrl.text,
      'quantity': int.tryParse(_qtyCtrl.text) ?? 1,
      'cost_price': double.tryParse(_priceCtrl.text) ?? 0,
      'category': _categoryCtrl.text.isEmpty ? null : _categoryCtrl.text,
      'business_id': businessId,
    });
    ref.invalidate(inventoryProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Product Name', prefixIcon: Icon(LucideIcons.package))),
          const SizedBox(height: 16),
          TextField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: 'Category (optional)', prefixIcon: Icon(LucideIcons.tag))),
          const SizedBox(height: 16),
          TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity', prefixIcon: Icon(LucideIcons.hash))),
          const SizedBox(height: 16),
          TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price', prefixIcon: Icon(LucideIcons.dollarSign))),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(LucideIcons.check, size: 18),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
