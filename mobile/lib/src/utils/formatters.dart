import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat brl = NumberFormat.simpleCurrency(locale: 'pt_BR');
  static final NumberFormat percent = NumberFormat.decimalPercentPattern(
    locale: 'pt_BR',
    decimalDigits: 2,
  );
  static final NumberFormat number2 = NumberFormat.decimalPattern('pt_BR');

  static String money(num value) => brl.format(value);
  static String pct(num value) => percent.format(value);
  static String num2(num value) => number2.format(value);
}
