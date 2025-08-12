class TimezoneUtils {
  /// Get user's current timezone
  static String getUserTimezone() {
    return DateTime.now().timeZoneName;
  }

  /// Get user's timezone offset in minutes
  static int getUserTimezoneOffset() {
    final now = DateTime.now();
    return now.timeZoneOffset.inMinutes;
  }

  /// Convert UTC DateTime to user's local timezone
  static DateTime utcToLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Convert local DateTime to UTC
  static DateTime localToUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }

  /// Get the start of day in user's timezone (00:00:00)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of day in user's timezone (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get today's date string in user's timezone (YYYY-MM-DD format)
  static String getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Check if a UTC timestamp falls within today in user's timezone
  static bool isToday(DateTime utcDateTime) {
    final localDateTime = utcToLocal(utcDateTime);
    final today = DateTime.now();

    return localDateTime.year == today.year &&
        localDateTime.month == today.month &&
        localDateTime.day == today.day;
  }

  /// Get the date string for a specific UTC timestamp in user's timezone
  static String getDateStringFromUtc(DateTime utcDateTime) {
    final localDateTime = utcToLocal(utcDateTime);
    return '${localDateTime.year}-${localDateTime.month.toString().padLeft(2, '0')}-${localDateTime.day.toString().padLeft(2, '0')}';
  }

  /// Format duration for display (HH:MM:SS)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration for display (HH:MM)
  static String formatDurationShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Get current UTC timestamp
  static DateTime getCurrentUtcTime() {
    return DateTime.now().toUtc();
  }

  /// Get current local timestamp
  static DateTime getCurrentLocalTime() {
    return DateTime.now();
  }
}
