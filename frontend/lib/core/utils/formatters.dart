import 'package:intl/intl.dart';

import '../config/app_config.dart';

// helpers to format prices and times
class Formatters {
  const Formatters._();

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  // price with two decimals and the currency, like "4.50 JD".
  static String price(num value) => '${_money.format(value)} ${AppConfig.currency}';

  // time in the device's time zone (the server sends UTC).
  static String time(DateTime utc) => _time.format(utc.toLocal());

  // date and time in the device's time zone.
  static String dateTime(DateTime utc) => _dateTime.format(utc.toLocal());
}
