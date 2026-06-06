class SaleItem {
  final String id;
  final String itemName;
  final int quantity;
  final double salePrice;
  final double costPrice;
  final DateTime createdAt;

  SaleItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.salePrice,
    required this.costPrice,
    required this.createdAt,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'].toString(),
      itemName: map['item_name'] ?? '',
      quantity: (map['quantity'] as num).toInt(),
      salePrice: (map['sale_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  double get totalRevenue => quantity * salePrice;
  double get totalProfit => (salePrice - costPrice) * quantity;
}
