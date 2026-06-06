import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jewelry_ledger/core/providers.dart';
import 'package:jewelry_ledger/features/dashboard/data/dashboard_repository.dart';
import 'package:jewelry_ledger/features/dashboard/domain/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DashboardRepository(client);
});

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _repository.fetchStats();
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardStats>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});
