import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewelry_ledger/features/clients/domain/client.dart';

class ClientRepository {
  final SupabaseClient _client;

  ClientRepository(this._client);

  Future<List<Client>> fetchAll(String businessId) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);
      return (response as List).map((m) => Client.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addClient(Map<String, dynamic> data) async {
    await _client.from('customers').insert(data);
  }

  Future<void> recordPayment(String customerId, double amount) async {
    final response = await _client
        .from('customers')
        .select('amount, total_paid')
        .eq('id', customerId)
        .single();
    final currentAmount = ((response['amount'] as num?) ?? 0).toDouble();
    final currentPaid = ((response['total_paid'] as num?) ?? 0).toDouble();
    final newAmount = (currentAmount - amount).clamp(0, double.infinity);
    await _client.from('customers').update({
      'amount': newAmount,
      'total_paid': currentPaid + amount,
    }).eq('id', customerId);
  }
}
