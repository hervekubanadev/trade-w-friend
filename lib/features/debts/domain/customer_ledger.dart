class CustomerLedger {
  final String id;
  final String name;
  final String? phone;
  final double totalDebt;
  final double totalPaid;
  final DateTime createdAt;
  final DateTime? dueDate;

  CustomerLedger({
    required this.id,
    required this.name,
    this.phone,
    required this.totalDebt,
    required this.totalPaid,
    required this.createdAt,
    this.dueDate,
  });

  factory CustomerLedger.fromMap(Map<String, dynamic> map) {
    return CustomerLedger(
      id: map['id'].toString(),
      name: map['name'] ?? 'Unknown',
      phone: map['phone'],
      totalDebt: (map['amount'] as num?)?.toDouble() ?? 0, // In this schema, amount is the remaining debt
      totalPaid: 0, // This needs to be calculated from debt_payments
      createdAt: DateTime.parse(map['created_at']),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    );
  }

  double get remainingDebt => totalDebt - totalPaid;
}
