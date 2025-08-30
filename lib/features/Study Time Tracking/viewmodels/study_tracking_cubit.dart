import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/daily_study_service.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/viewmodels/study_tracking_states.dart';

class StudyTrackingCubit extends Cubit<StudyTrackingStates> {
  final DailyStudyService _studyService = DailyStudyService();

  StudyTrackingCubit() : super(StudyTrackingInitialState());

  /// Load today's study time
  Future<void> loadDailyStudyTime() async {
    emit(StudyTrackingLoadingState());

    try {
      final studyTime = await _studyService.getDailyStudyTime();
      emit(StudyTrackingLoadedState(studyTime));
    } on Exception catch (e) {
      e;
      emit(StudyTrackingErrorState('Failed to load daily study time: $e'));
    }
  }

  /// Add study time to today's total
  Future<void> addStudyTime(Duration studyTime) async {
    try {
      await _studyService.addStudyTime(studyTime);
      await loadDailyStudyTime(); // Reload to get updated time
    } on Exception catch (e) {
      e;
      emit(StudyTrackingErrorState('Failed to add study time: $e'));
    }
  }

  /// Get study time for a specific date
  // Future<Duration> getStudyTimeForDate(String date) async {
  //   try {
  //     return await _studyService.getStudyTimeForDate(date);
  //   } on Exception catch (e) {
  //     e;
  //     emit(StudyTrackingErrorState('Failed to get study time for date: $e'));
  //     return Duration.zero;
  //   }
  // }

  /// Get study time for the last N days
  Future<Map<String, Duration>> getStudyTimeForLastDays(int days) async {
    try {
      return await _studyService.getStudyTimeForLastDays(days);
    } on Exception catch (e) {
      e;
      emit(
        StudyTrackingErrorState('Failed to get study time for last days: $e'),
      );
      return {};
    }
  }

  /// Get total study time across all days
  Future<Duration> getTotalStudyTime() async {
    try {
      return await _studyService.getTotalStudyTime();
    } on Exception catch (e) {
      e;
      emit(StudyTrackingErrorState('Failed to get total study time: $e'));
      return Duration.zero;
    }
  }

  /// Reset today's study time
  Future<void> resetDailyStudyTime() async {
    try {
      await _studyService.resetDailyStudyTime();
      await loadDailyStudyTime(); // Reload to get updated time
    } on Exception catch (e) {
      e;
      emit(StudyTrackingErrorState('Failed to reset daily study time: $e'));
    }
  }
}
