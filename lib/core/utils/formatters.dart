import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount, {
    String currencyCode = 'INR',
    bool withSign = false,
    bool negative = false,
  }) {
    final format = NumberFormat.currency(
      locale: _localeFor(currencyCode),
      symbol: _symbolFor(currencyCode),
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );
    final value = negative ? -amount.abs() : amount;
    final formatted = format.format(value.abs());
    if (withSign || negative) {
      final sign = (negative || value < 0) ? '-' : '+';
      return '$sign$formatted';
    }
    return formatted;
  }

  static String _symbolFor(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'AED':
        return 'AED ';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'SGD':
        return 'S\$';
      case 'INR':
        return '₹';
      default:
        return '${code.toUpperCase()} ';
    }
  }

  static String _localeFor(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return 'en_US';
      case 'EUR':
        return 'en_IE';
      case 'GBP':
        return 'en_GB';
      case 'AED':
        return 'en_AE';
      case 'JPY':
        return 'ja_JP';
      case 'AUD':
        return 'en_AU';
      case 'CAD':
        return 'en_CA';
      case 'SGD':
        return 'en_SG';
      case 'INR':
      default:
        return 'en_IN';
    }
  }
}

class DateFormatter {
  DateFormatter._();

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String dayMonthYear(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String shortDate(DateTime date) => DateFormat('dd MMM').format(date);

  static String isoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static DateTime parseIsoDate(String value) =>
      DateTime.parse(value.length > 10 ? value : '${value}T00:00:00');

  static String greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
