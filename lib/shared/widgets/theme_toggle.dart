import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return IconButton(
      onPressed: () {
        ref.read(themeModeProvider.notifier).update((state) {
          if (state == ThemeMode.light) return ThemeMode.dark;
          if (state == ThemeMode.dark) return ThemeMode.system;
          return ThemeMode.light;
        });
      },
      icon: Icon(
        mode == ThemeMode.dark ? LucideIcons.moon :
        mode == ThemeMode.light ? LucideIcons.sun : LucideIcons.monitor,
        size: 20,
      ),
    );
  }
}
