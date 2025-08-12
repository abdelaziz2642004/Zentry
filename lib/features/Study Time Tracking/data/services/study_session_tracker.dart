import 'dart:async';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/daily_study_service.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';

class StudySessionTracker {
  final DailyStudyService _studyService = DailyStudyService();
  Timer? _sessionTimer;
  Timer? _minuteTimer;
  DateTime? _sessionStartTime;
  int _workDurationMinutes = 0;
  bool _isTracking = false;
  int _lastMinuteAdded = 0;

  /// Start tracking a work session
  void startWorkSession(int workDurationMinutes) {
    if (_isTracking) {
      stopWorkSession(); // Stop any existing session
    }

    _workDurationMinutes = workDurationMinutes;
    _sessionStartTime = TimezoneUtils.getCurrentUtcTime();
    _isTracking = true;
    _lastMinuteAdded = 0;

    // Start a timer that fires every minute to add study time
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _addStudyTimeIfInWorkPhase();
    });
  }

  /// Add study time every minute during work phase
  void _addStudyTimeIfInWorkPhase() {
    if (!_isTracking || _sessionStartTime == null) {
      return;
    }

    final now = TimezoneUtils.getCurrentUtcTime();
    final elapsedMinutes = now.difference(_sessionStartTime!).inMinutes;

    // Only add time if we're still in the work phase
    if (elapsedMinutes < _workDurationMinutes) {
      // Add 1 minute of study time
      _studyService.addStudyTime(const Duration(minutes: 1));
      _lastMinuteAdded = elapsedMinutes;
    } else {
      // Work phase is complete, stop the timer
      stopWorkSession();
    }
  }

  /// Stop tracking the current work session
  Future<void> stopWorkSession() async {
    if (!_isTracking) {
      return;
    }

    _minuteTimer?.cancel();
    _isTracking = false;
    _sessionStartTime = null;
    _workDurationMinutes = 0;
    _lastMinuteAdded = 0;
  }

  /// Pause the current work session (for breaks)
  void pauseWorkSession() {
    if (_isTracking) {
      _minuteTimer?.cancel();
    }
  }

  /// Resume the current work session (after breaks)
  void resumeWorkSession() {
    if (_isTracking) {
      // Restart the minute timer
      _minuteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _addStudyTimeIfInWorkPhase();
      });
    }
  }

  /// Check if currently tracking a session
  bool get isTracking => _isTracking;

  /// Get the current session start time
  DateTime? get sessionStartTime => _sessionStartTime;

  /// Get the work duration being tracked
  int get workDurationMinutes => _workDurationMinutes;

  /// Get the elapsed time of the current session
  Duration get elapsedTime {
    if (!_isTracking || _sessionStartTime == null) {
      return Duration.zero;
    }

    final now = TimezoneUtils.getCurrentUtcTime();
    return now.difference(_sessionStartTime!);
  }

  /// Get remaining time in the current session
  Duration get remainingTime {
    if (!_isTracking || _workDurationMinutes == 0) {
      return Duration.zero;
    }

    final elapsed = elapsedTime;
    final total = Duration(minutes: _workDurationMinutes);

    if (elapsed >= total) {
      return Duration.zero;
    }

    return total - elapsed;
  }

  /// Get the last minute that was added to study time
  int get lastMinuteAdded => _lastMinuteAdded;

  /// Dispose of the tracker
  void dispose() {
    stopWorkSession();
    _sessionTimer?.cancel();
  }
}
