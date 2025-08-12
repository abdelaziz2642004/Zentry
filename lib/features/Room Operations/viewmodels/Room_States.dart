import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';

class RoomStates {}

// Room General states

class RoomInitialState extends RoomStates {}

class RoomLoadingState extends RoomStates {}

// RoomCreation States

class RoomCreationSuccess extends RoomStates {
  final String roomCode;
  RoomCreationSuccess(this.roomCode);
}

class RoomCreationFailure extends RoomStates {
  final String error;
  RoomCreationFailure(this.error);
}

class RoomCreatingLoadingState extends RoomStates {}

// RoomJoin States

class RoomJoinSuccess extends RoomStates {
  PomodoroRoom room;
  RoomJoinSuccess(this.room);
}

/// Emitted when the list of joined users in a room changes (not necessarily the current user)
class RoomUsersUpdated extends RoomStates {
  PomodoroRoom room;
  RoomUsersUpdated(this.room);
}

class RoomJoinFailure extends RoomStates {
  final String error;
  RoomJoinFailure(this.error);
}

class RoomJoinLoadingState extends RoomStates {}

// RoomLeave States

class RoomLeaveSuccess extends RoomStates {}

class RoomLeaveFailure extends RoomStates {
  final String error;
  RoomLeaveFailure(this.error);
}

// RoomUpdate States
class RoomUpdateSuccess extends RoomStates {
  PomodoroRoom room;
  RoomUpdateSuccess(this.room);
}

class RoomUpdateFailure extends RoomStates {
  final String error;
  RoomUpdateFailure(this.error);
}

class RecentlyUpdated extends RoomStates {}
