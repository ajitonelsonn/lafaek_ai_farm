/// Small, dependency-free formatting helpers.
class Formatters {
  Formatters._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _monthsLong = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  /// e.g. "Sep 20, 2026"
  static String shortDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// e.g. "September 20, 2026"
  static String longDate(DateTime d) =>
      '${_monthsLong[d.month - 1]} ${d.day}, ${d.year}';

  /// e.g. "Mon, Sep 20"
  static String weekdayDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

  /// e.g. "Mon" — for chart axes, where space is tight.
  static String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

  /// e.g. "9:40 AM"
  static String time(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final suffix = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  /// e.g. "10 AM"
  static String hourLabel(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final suffix = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour $suffix';
  }

  /// e.g. "2 hours ago", "1 day ago", "Just now"
  static String timeAgo(DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return shortDate(d);
  }

  /// Time-of-day greeting.
  static String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  static String hectares(double ha) {
    final s = ha.toStringAsFixed(ha.truncateToDouble() == ha ? 1 : 1);
    return '$s ha';
  }
}
