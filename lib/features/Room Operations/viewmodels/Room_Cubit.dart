import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/room_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class RoomCubit extends Cubit<RoomStates> {
  final RoomRepository roomRepository;
  StreamSubscription<List<String>>? _joinedUsersSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  ConnectivityResult? _lastConnectivityResult;
  PomodoroRoom? recently;
  List<String> _previousUserIds = [];

  RoomCubit(this.roomRepository) : super(RoomInitialState()) {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (_lastConnectivityResult == ConnectivityResult.none &&
        result != ConnectivityResult.none) {
      if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
        final room = (state as dynamic).room as PomodoroRoom;
        forceRejoin(room.roomCode);
      }
    }
    _lastConnectivityResult = result;
  }

  Future<void> forceRejoin(String roomCode) async {
    try {
      await roomRepository.leaveRoom(roomCode);
      final room = await roomRepository.joinRoom(roomCode);

      if (room == null) {
        emit(RoomJoinFailure("Room not found or has finished"));
        return;
      }

      recently = room;
      _previousUserIds = room.joinedUsers.toList();
      emit(RecentlyUpdated());

      _startListeningToJoinedUsers(room);

      emit(RoomJoinSuccess(room));
    } on Exception catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<String> atStart(FireUser user) async {
    emit(RoomLoadingState());

    try {
      final room = await roomRepository.recentlyFetch();
      if (room != null) {
        // Check if the room still exists and is not finished
        final roomRef = FirebaseDatabase.instance.ref(
          FirebaseConstants.getRoomPath(room.roomCode),
        );
        final roomSnapshot = await roomRef.get();

        if (!roomSnapshot.exists || room.isFinished) {
          // Room doesn't exist or is finished, clear it
          await _clearRecentlyJoinedRoom(user.id);
          emit(RoomInitialState());
          return "";
        }

        recently = room;
        emit(RecentlyUpdated());
      }

      final joinedRoomCode = await roomRepository.joinedRoomFetch();
      if (joinedRoomCode == null || joinedRoomCode == "") {
        emit(RoomInitialState());
        return "";
      } else {
        emit(RoomInitialState());
        return joinedRoomCode;
      }
    } on Exception catch (e) {
      e;
      emit(RoomJoinFailure("Error during startup: ${e.toString()}"));
      return "";
    }
  }

  /// Clear the recently joined room from the database
  Future<void> _clearRecentlyJoinedRoom(String userId) async {
    final userDbRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getUserPath(userId),
    );
    await userDbRef.child("recently").remove();
    await userDbRef.child("joinedroom").remove();
  }

  Future<String?> createRoom(PomodoroRoom room) async {
    emit(RoomCreatingLoadingState());
    try {
      final DateTime createdAt = room.createdAt.toDate();
      final DateTime scheduleTime = room.scheduleTime.toDate();

      if (room.isScheduled && createdAt.isAfter(scheduleTime)) {
        throw ("Scheduler must be AFTER created time");
      }
      await roomRepository.createRoom(room);
      emit(RoomCreationSuccess(room.roomCode));
      return room.roomCode;
    } on Exception catch (e) {
      e;
      emit(RoomCreationFailure(e.toString()));
      return null;
    }
  }

  Future<void> joinRoom(String roomCode) async {
    // Prevent multiple simultaneous join attempts
    final currentState = state;
    if (currentState.runtimeType.toString() == 'RoomJoinLoadingState') {
      return;
    }

    emit(RoomJoinLoadingState());
    try {
      final room = await roomRepository.joinRoom(roomCode);

      if (room == null) {
        // Room was deleted (finished) or doesn't exist
        emit(RoomJoinFailure("Room not found or has finished"));

        // Clear the recently joined room from the database
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userDbRef = FirebaseDatabase.instance.ref(
            FirebaseConstants.getUserPath(user.uid),
          );
          await userDbRef.child("recently").remove();
          await userDbRef.child("joinedroom").remove();
        }

        return;
      }

      recently = room;
      _previousUserIds = room.joinedUsers.toList();
      emit(RecentlyUpdated());

      // Start listening to joined users changes
      _startListeningToJoinedUsers(room);

      emit(RoomJoinSuccess(room));
    } on Exception catch (e) {
      e;
      emit(RoomJoinFailure(e.toString()));
    }
  }

  Future<void> leaveRoom(String roomCode) async {
    emit(RoomJoinLoadingState());
    try {
      await roomRepository.leaveRoom(roomCode);

      // Stop listening to joined users
      _stopListeningToJoinedUsers();
      _previousUserIds = [];

      emit(RoomLeaveSuccess());
    } on Exception catch (e) {
      e;
      emit(RoomLeaveFailure(e.toString()));
    }
  }

  // Start listening to joined users changes
  void _startListeningToJoinedUsers(PomodoroRoom room) {
    _stopListeningToJoinedUsers(); // Stop any existing subscription

    _joinedUsersSubscription = room.listenToJoinedUsers().listen(
      (List<String> newUserIds) {
        final disconnectedUsers =
            _previousUserIds.where((id) => !newUserIds.contains(id)).toList();

        room.updateJoinedUsers(newUserIds);
        _previousUserIds = newUserIds.toList();

        emit(RoomUsersUpdated(room, disconnectedUsers));
      },
      onError: (error) {
        emit(RoomFailure("Error listening to room users: $error"));
      },
    );
  }

  // Stop listening to joined users
  void _stopListeningToJoinedUsers() {
    _joinedUsersSubscription?.cancel();
    _joinedUsersSubscription = null;
  }

  void leaveRoomLocally() {
    _stopListeningToJoinedUsers();
    _previousUserIds = [];
    emit(RoomLeaveSuccess());
  }

  @override
  Future<void> close() {
    _stopListeningToJoinedUsers();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
