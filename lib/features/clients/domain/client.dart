class Client {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final double totalDebt;
  final double totalPaid;
  final String? businessId;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.totalDebt = 0,
    this.totalPaid = 0,
    this.businessId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'].toString(),
      name: map['name'] ?? 'Unknown',
      phone: map['phone'],
      email: map['email'],
      totalDebt: (map['amount'] as num?)?.toDouble() ?? 0,
      totalPaid: (map['total_paid'] as num?)?.toDouble() ?? 0,
      businessId: map['business_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  double get remainingDebt => totalDebt - totalPaid;
}
