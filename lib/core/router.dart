import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jewelry_ledger/features/auth/presentation/auth_screen.dart';
import 'package:jewelry_ledger/features/clients/presentation/clients_screen.dart';
import 'package:jewelry_ledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:jewelry_ledger/features/debts/presentation/debts_screen.dart';
import 'package:jewelry_ledger/features/inventory/presentation/add_product_screen.dart';
import 'package:jewelry_ledger/features/inventory/presentation/inventory_screen.dart';
import 'package:jewelry_ledger/features/kiosk/presentation/kiosk_settings_screen.dart';
import 'package:jewelry_ledger/features/sales/presentation/record_sale_screen.dart';
import 'package:jewelry_ledger/features/sales/presentation/sales_report_screen.dart';
import 'package:jewelry_ledger/features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/inventory', builder: (_, __) => const InventoryScreen()),
      GoRoute(path: '/inventory/add', builder: (_, __) => const AddProductScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const SalesReportScreen()),
      GoRoute(path: '/sales/new', builder: (_, __) => const RecordSaleScreen()),
      GoRoute(path: '/debts', builder: (_, __) => const DebtsScreen()),
      GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/kiosk-settings', builder: (_, __) => const KioskSettingsScreen()),
    ],
  );
});
