import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jewelry_ledger/core/kiosk_manager.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/features/auth/application/auth_notifier.dart';
import 'package:jewelry_ledger/features/dashboard/application/dashboard_notifier.dart';
import 'package:jewelry_ledger/features/kiosk/presentation/kiosk_lock_screen.dart';
import 'package:jewelry_ledger/shared/utils/currency_utils.dart';
import 'package:jewelry_ledger/shared/widgets/glass_card.dart';
import 'package:jewelry_ledger/shared/widgets/stat_card.dart';
import 'package:jewelry_ledger/shared/widgets/theme_toggle.dart';
import 'package:jewelry_ledger/shared/widgets/workspace_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !KioskManager.instance.isEnabled,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && KioskManager.instance.isEnabled && KioskManager.instance.isLocked) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KioskLockScreen()));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.grey.shade400 : AppColors.textTertiary)),
                        Text(
                          authState.profile?.businessName ?? 'TradeWFriend+',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const ThemeToggle(),
                        IconButton(
                          onPressed: () => context.push('/settings'),
                          icon: Icon(LucideIcons.settings, color: isDark ? Colors.grey.shade400 : AppColors.textSecondary),
                        ),
                        IconButton(
                          onPressed: () => ref.read(authProvider.notifier).logout(),
                          icon: const Icon(LucideIcons.logOut, color: AppColors.error),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                statsAsync.when(
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(LucideIcons.cloudOff, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('Could not load data', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),
                  data: (stats) => Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          StatCard(label: 'Revenue', value: CurrencyUtils.format(stats.totalRevenue), icon: LucideIcons.wallet, color: AppColors.primary),
                          StatCard(label: 'Debt', value: CurrencyUtils.format(stats.totalDebt), icon: LucideIcons.receipt, color: AppColors.error),
                          StatCard(label: 'Inventory', value: CurrencyUtils.format(stats.inventoryValue), icon: LucideIcons.package, color: AppColors.accent),
                          StatCard(label: 'Today', value: CurrencyUtils.format(stats.todayRevenue), icon: LucideIcons.trendingUp, color: AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Workspace', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    WorkspaceButton(label: 'Inventory', icon: LucideIcons.package, color: AppColors.primary, onTap: () => context.push('/inventory')),
                    WorkspaceButton(label: 'New Sale', icon: LucideIcons.shoppingCart, color: AppColors.success, onTap: () => context.push('/sales/new')),
                    WorkspaceButton(label: 'Clients', icon: LucideIcons.users, color: AppColors.accent, onTap: () => context.push('/clients')),
                    WorkspaceButton(label: 'Debts', icon: LucideIcons.receipt, color: AppColors.warning, onTap: () => context.push('/debts')),
                    WorkspaceButton(label: 'Reports', icon: LucideIcons.barChart3, color: Colors.pink, onTap: () => context.push('/reports')),
                    WorkspaceButton(label: 'Kiosk', icon: LucideIcons.shield, color: AppColors.primary, onTap: () => context.push('/kiosk-settings')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
