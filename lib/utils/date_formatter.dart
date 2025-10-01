import 'package:intl/intl.dart';

class DateFormatter {
  // Format date as 'Jan 1, 2024'
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Format time as '2:30 PM'
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Format date and time as 'Jan 1, 2024 at 2:30 PM'
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  // Format as 'Today at 2:30 PM' or 'Tomorrow at 2:30 PM' or full date
  static String formatRelativeDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today at ${formatTime(date)}';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow at ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  // Format as '2 hours ago' or '5 minutes ago'
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Format as 'in 2 hours' or 'in 5 minutes'
  static String formatTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'in $years ${years == 1 ? 'year' : 'years'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Less than a minute';
    }
  }

  // Format as short date '01/15/2024'
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  // Format as long date 'Monday, January 1, 2024'
  static String formatLongDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  // Format as day of week 'Monday'
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Format as month and year 'January 2024'
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Parse natural language time (e.g., 'tomorrow at 5pm', 'in 2 hours')
  static DateTime? parseNaturalTime(String input) {
    input = input.toLowerCase().trim();
    final now = DateTime.now();

    try {
      // Handle 'tomorrow at X'
      if (input.contains('tomorrow')) {
        final timeMatch = RegExp(r'(\d+)\s*(am|pm)').firstMatch(input);
        if (timeMatch != null) {
          int hour = int.parse(timeMatch.group(1)!);
          if (timeMatch.group(2) == 'pm' && hour != 12) hour += 12;
          if (timeMatch.group(2) == 'am' && hour == 12) hour = 0;

          return DateTime(now.year, now.month, now.day + 1, hour, 0);
        }
      }

      // Handle 'today at X'
      if (input.contains('today')) {
        final timeMatch = RegExp(r'(\d+)\s*(am|pm)').firstMatch(input);
        if (timeMatch != null) {
          int hour = int.parse(timeMatch.group(1)!);
          if (timeMatch.group(2) == 'pm' && hour != 12) hour += 12;
          if (timeMatch.group(2) == 'am' && hour == 12) hour = 0;

          return DateTime(now.year, now.month, now.day, hour, 0);
        }
      }

      // Handle 'in X hours'
      if (input.contains('in') && input.contains('hour')) {
        final hourMatch = RegExp(r'in\s*(\d+)\s*hour').firstMatch(input);
        if (hourMatch != null) {
          final hours = int.parse(hourMatch.group(1)!);
          return now.add(Duration(hours: hours));
        }
      }

      // Handle 'in X minutes'
      if (input.contains('in') && input.contains('minute')) {
        final minuteMatch = RegExp(r'in\s*(\d+)\s*minute').firstMatch(input);
        if (minuteMatch != null) {
          final minutes = int.parse(minuteMatch.group(1)!);
          return now.add(Duration(minutes: minutes));
        }
      }

      // Handle 'at X pm/am'
      final timeMatch = RegExp(r'at\s*(\d+)\s*(am|pm)').firstMatch(input);
      if (timeMatch != null) {
        int hour = int.parse(timeMatch.group(1)!);
        if (timeMatch.group(2) == 'pm' && hour != 12) hour += 12;
        if (timeMatch.group(2) == 'am' && hour == 12) hour = 0;

        return DateTime(now.year, now.month, now.day, hour, 0);
      }

      return null;
    } catch (e) {
      print('Error parsing natural time: $e');
      return null;
    }
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
