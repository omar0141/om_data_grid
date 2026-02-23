import 'package:intl/intl.dart';

class OmGridCellFormatters {
  static final Map<String, DateFormat> _dateFormats = {};
  static final RegExp thousandsRegExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  static DateFormat getDateFormat(String pattern) {
    return _dateFormats.putIfAbsent(pattern, () => DateFormat(pattern));
  }

  static String formatNumber({
    required double value,
    int? digits,
    String? decimalSeparator,
    String? thousandsSeparator,
  }) {
    final int d = digits ?? 2;
    final String ds = decimalSeparator ?? '.';
    final String ts = thousandsSeparator ?? '';

    String fixed = value.toStringAsFixed(d);
    if (ts.isEmpty && ds == '.') return fixed;

    List<String> parts = fixed.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    if (ts.isNotEmpty) {
      integerPart = integerPart.replaceAllMapped(
        thousandsRegExp,
        (Match m) => '${m[1]}$ts',
      );
    }

    if (d > 0) {
      return '$integerPart$ds$decimalPart';
    }
    return integerPart;
  }
}

class OmGridCellConstants {
  static final DateFormat defaultDateFormatter = DateFormat.yMd();
}
