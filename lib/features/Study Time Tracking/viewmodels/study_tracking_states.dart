
abstract class StudyTrackingStates {}

class StudyTrackingInitialState extends StudyTrackingStates {}

class StudyTrackingLoadingState extends StudyTrackingStates {}

class StudyTrackingLoadedState extends StudyTrackingStates {
  final Duration dailyStudyTime;

  StudyTrackingLoadedState(this.dailyStudyTime);
}

class StudyTrackingErrorState extends StudyTrackingStates {
  final String message;

  StudyTrackingErrorState(this.message);
}
