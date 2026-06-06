import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/shared/widgets/app_bottom_sheet.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    if (profile != null) {
      _nameCtrl.text = profile.displayName;
      _phoneCtrl.text = profile.phone;
      _businessCtrl.text = profile.businessName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _businessCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final supabase = ref.read(supabaseClientProvider);
    final profile = ref.read(authProvider).profile;
    if (profile == null) return;
    await supabase.from('employees').update({
      'display_name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'business_name': _businessCtrl.text,
    }).eq('id', profile.id);
    if (mounted) setState(() => _saving = false);
  }

  void _confirmReset() {
    showAppSheet(context, title: 'Reset App', child: Column(
      children: [
        const Text('This will clear all local data and sign you out. Continue?', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        sheetButton(label: 'Reset & Log Out', color: AppColors.error, onPressed: () {
          ref.read(authProvider.notifier).logout();
          Navigator.pop(context);
        }),
        const SizedBox(height: 8),
        sheetButton(label: 'Cancel', outline: true, onPressed: () => Navigator.pop(context)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Business Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(LucideIcons.user))),
                const SizedBox(height: 16),
                TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(LucideIcons.phone)), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextField(controller: _businessCtrl, decoration: const InputDecoration(labelText: 'Business Name', prefixIcon: Icon(LucideIcons.store))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.save, size: 20),
              label: Text(_saving ? 'Saving...' : 'Save Changes'),
            ),
          ),
          const SizedBox(height: 32),
          Text('App Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _infoRow('Version', '1.0.0', isDark),
                const Divider(),
                _infoRow('Build', '2025.1', isDark),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton.icon(
              onPressed: _confirmReset,
              icon: const Icon(LucideIcons.trash2, color: AppColors.error),
              label: const Text('Factory Reset', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
