class InventoryItem {
  final String id;
  final String itemName;
  final int quantity;
  final double costPrice;
  final String? category;
  final String? subcategory;
  final DateTime? createdAt;

  InventoryItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.costPrice,
    this.category,
    this.subcategory,
    this.createdAt,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'].toString(),
      itemName: map['item_name'] ?? '',
      quantity: (map['quantity'] as num).toInt(),
      costPrice: (map['cost_price'] as num).toDouble(),
      category: map['category'],
      subcategory: map['subcategory'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  double get totalValue => quantity * costPrice;

  String get stockStatus {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= 5) return 'Low Stock';
    return 'In Stock';
  }
}
