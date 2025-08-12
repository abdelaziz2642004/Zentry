class ProfileStates {}

class ProfileInitialState extends ProfileStates {}

class ProfileLoadingState extends ProfileStates {}

class ProfileSuccessState extends ProfileStates {}

class ProfileImageSuccessState extends ProfileStates {
  String imageUrl = "";
  ProfileImageSuccessState(this.imageUrl);
}

class ProfileErrorState extends ProfileStates {
  final String error;
  ProfileErrorState(this.error);
}

class FullNameErrorState extends ProfileStates {
  final String error;
  FullNameErrorState(this.error);
}

class FullNameSuccessState extends ProfileStates {}
