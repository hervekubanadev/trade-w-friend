import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_RW',
      symbol: 'RWF ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
