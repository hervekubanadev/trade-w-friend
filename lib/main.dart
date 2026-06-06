import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/kiosk_manager.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:jewelry_ledger/core/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://ujspobpaslhqozpsztlx.supabase.co',
      publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqc3BvYnBhc2xocW96cHN6dGx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4MDU1NTYsImV4cCI6MjA5MTM4MTU1Nn0.Mgou-bVxuBWbeV9Y2kFPKS2y50gNHovkSku1LBb8dic',
    );
  } catch (_) {}
  await KioskManager.instance.init();
  runApp(const ProviderScope(child: _App()));
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'TradeWFriend+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
