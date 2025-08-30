import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

abstract class GroupsState {}

class GroupsInitialState extends GroupsState {}

class GroupsLoadingState extends GroupsState {}

// Separate loading states for different tabs
class PublicGroupsLoadingState extends GroupsState {}

class UserGroupsLoadingState extends GroupsState {}

class GroupsErrorState extends GroupsState {
  final String error;
  GroupsErrorState(this.error);
}

// Public Groups States
class PublicGroupsLoadedState extends GroupsState {
  final List<StudyGroup> groups;
  PublicGroupsLoadedState(this.groups);
}

// User's Joined Groups States
class UserGroupsLoadedState extends GroupsState {
  final List<StudyGroup> groups;
  UserGroupsLoadedState(this.groups);
}

// Group Creation States
class GroupCreatingState extends GroupsState {}

class GroupCreatedState extends GroupsState {
  final String groupId;
  GroupCreatedState(this.groupId);
}

class GroupCreationFailedState extends GroupsState {
  final String error;
  GroupCreationFailedState(this.error);
}

// Group Join/Leave States
class GroupJoiningState extends GroupsState {}

class GroupJoinedState extends GroupsState {}

class GroupLeavingState extends GroupsState {}

class GroupLeftState extends GroupsState {}

// Group Search States
class GroupsSearchResultState extends GroupsState {
  final List<StudyGroup> groups;
  GroupsSearchResultState(this.groups);
}

class GroupsSearchClearedState extends GroupsState {}

// Group Details States
class GroupDetailsLoadedState extends GroupsState {
  final StudyGroup group;
  GroupDetailsLoadedState(this.group);
}

// Group Management States
class AdminAddedState extends GroupsState {}

class AdminRemovedState extends GroupsState {}
