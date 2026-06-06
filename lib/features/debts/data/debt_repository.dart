import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewelry_ledger/features/debts/domain/customer_ledger.dart';

class DebtRepository {
  final SupabaseClient _client;

  DebtRepository(this._client);

  Future<List<CustomerLedger>> fetchLedgers() async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((m) => CustomerLedger.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> recordPayment(String customerId, double amount) async {
    // Basic implementation: decrement amount in customers table
    // In a real app, this should also insert into debt_payments
    final response = await _client.from('customers').select('amount').eq('id', customerId).single();
    final currentAmount = (response['amount'] as num).toDouble();
    final newAmount = (currentAmount - amount).clamp(0, double.infinity);
    
    await _client.from('customers').update({'amount': newAmount}).eq('id', customerId);
  }
}
