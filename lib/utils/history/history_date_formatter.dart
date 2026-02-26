// lib/screens/history/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String getDateNumber(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return date.day.toString();
    } catch (e) {
      return '1';
    }
  }

  static String getMonthText(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[date.month - 1];
    } catch (e) {
      return 'Jan';
    }
  }

  static String formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
