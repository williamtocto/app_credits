import 'package:intl/intl.dart';

class Formatters {
  static String currency(double value) => value.toStringAsFixed(2);
  static String date(DateTime date) => DateFormat('MMM-yy').format(date);
}