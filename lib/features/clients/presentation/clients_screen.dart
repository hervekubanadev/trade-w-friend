import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/clients/application/client_notifier.dart';
import 'package:jewelry_ledger/features/clients/domain/client.dart';
import 'package:jewelry_ledger/shared/utils/currency_utils.dart';
import 'package:jewelry_ledger/shared/widgets/app_bottom_sheet.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showAddClient() {
    _nameCtrl.clear();
    _phoneCtrl.clear();
    showAppSheet(context, title: 'Add Client', child: Column(
      children: [
        sheetTextField(controller: _nameCtrl, hint: 'Full Name', icon: LucideIcons.user),
        sheetTextField(controller: _phoneCtrl, hint: 'Phone Number', icon: LucideIcons.phone, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        sheetButton(label: 'Add Client', onPressed: () async {
          if (_nameCtrl.text.isEmpty) return;
          final repo = ref.read(clientRepositoryProvider);
          await repo.addClient({
            'name': _nameCtrl.text,
            'phone': _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
          });
          ref.invalidate(clientsProvider);
          if (context.mounted) Navigator.pop(context);
        }),
      ],
    ));
  }

  void _showPayment(Client client) {
    final ctrl = TextEditingController();
    showAppSheet(context, title: 'Record Payment — ${client.name}', child: Column(
      children: [
        sheetTextField(controller: ctrl, hint: 'Amount', icon: LucideIcons.dollarSign, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        sheetButton(label: 'Record Payment', onPressed: () async {
          final repo = ref.read(clientRepositoryProvider);
          await repo.recordPayment(client.id, double.tryParse(ctrl.text) ?? 0);
          ref.invalidate(clientsProvider);
          if (context.mounted) Navigator.pop(context);
        }),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.userPlus, color: isDark ? Colors.white : AppColors.primary),
            onPressed: _showAddClient,
          ),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.users, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No clients yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Tap + to add a client', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: clients.length,
            itemBuilder: (_, i) {
              final client = clients[i];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48, width: 48,
                          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(LucideIcons.user, color: AppColors.accent, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
                              if (client.phone != null) Text(client.phone!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Text('Balance: ${CurrencyUtils.format(client.remainingDebt)}', style: TextStyle(fontSize: 12, color: client.remainingDebt > 0 ? AppColors.error : AppColors.success)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showPayment(client),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.dollarSign, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text('Pay', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
