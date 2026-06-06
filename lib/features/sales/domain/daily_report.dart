class DailyReport {
  final DateTime date;
  final double salesTotal;
  final double debtsPaid;
  final double unpaidDebt;
  final List<dynamic> sales; // List of SaleItem for that day

  DailyReport({
    required this.date,
    required this.salesTotal,
    required this.debtsPaid,
    required this.unpaidDebt,
    this.sales = const [],
  });

  double get receivedTotal => salesTotal + debtsPaid;
  double get expectedTotal => receivedTotal + unpaidDebt;
}
