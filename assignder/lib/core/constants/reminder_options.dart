class ReminderOptions {
  ReminderOptions._();

  static const String oneWeekBefore = '1_week_before';
  static const String threeDaysBefore = '3_days_before';
  static const String twentyFourHoursBefore = '24h_before';
  static const String twoHoursBefore = '2h_before';
  static const String oneHourBefore = '1h_before';
  static const String thirtyMinutesBefore = '30m_before';

  static const List<String> all = [
    oneWeekBefore,
    threeDaysBefore,
    twentyFourHoursBefore,
    twoHoursBefore,
    oneHourBefore,
    thirtyMinutesBefore,
  ];

  static String getLabel(String offset) {
    switch (offset) {
      case oneWeekBefore:
        return '1 week before';
      case threeDaysBefore:
        return '3 days before';
      case twentyFourHoursBefore:
        return '24 hours before';
      case twoHoursBefore:
        return '2 hours before';
      case oneHourBefore:
        return '1 hour before';
      case thirtyMinutesBefore:
        return '30 minutes before';
      default:
        return offset;
    }
  }

  static Duration getDuration(String offset) {
    switch (offset) {
      case oneWeekBefore:
        return const Duration(days: 7);
      case threeDaysBefore:
        return const Duration(days: 3);
      case twentyFourHoursBefore:
        return const Duration(hours: 24);
      case twoHoursBefore:
        return const Duration(hours: 2);
      case oneHourBefore:
        return const Duration(hours: 1);
      case thirtyMinutesBefore:
        return const Duration(minutes: 30);
      default:
        return const Duration(hours: 1);
    }
  }
}
