class DashboardStats {
  final double totalRevenue;
  final double totalDebt;
  final double inventoryValue;
  final double todayRevenue;
  final int totalCustomers;
  final int totalProducts;

  DashboardStats({
    this.totalRevenue = 0,
    this.totalDebt = 0,
    this.inventoryValue = 0,
    this.todayRevenue = 0,
    this.totalCustomers = 0,
    this.totalProducts = 0,
  });

  DashboardStats copyWith({
    double? totalRevenue,
    double? totalDebt,
    double? inventoryValue,
    double? todayRevenue,
    int? totalCustomers,
    int? totalProducts,
  }) {
    return DashboardStats(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalDebt: totalDebt ?? this.totalDebt,
      inventoryValue: inventoryValue ?? this.inventoryValue,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }
}
