import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class PomodoroRoom {
  String _roomCode = '';
  final String _creatorId;
  final Timestamp _createdAt;
  int _workDuration;
  int _breakDuration;
  int _totalSessions;
  bool _availableRoom;
  String _name;
  int _capacity;
  final bool isPublic;
  final List<String> tags;
  final List<String> joinedUsers;
  final bool isScheduled;
  final Timestamp scheduleTime;

  PomodoroRoom({
    String? roomCode,
    required String creatorId,
    required Timestamp createdAt,
    required bool availableRoom,
    required String name,
    required int capacity,
    required int workDuration,
    required int breakDuration,
    required this.isPublic,
    required int totalSessions,
    required this.tags,
    required this.joinedUsers,
    required this.isScheduled,
    required this.scheduleTime,
  }) : _creatorId = creatorId,
       _createdAt = createdAt,
       _availableRoom = availableRoom,
       _name = name,
       _capacity = capacity,
       _workDuration = workDuration,
       _breakDuration = breakDuration,
       _totalSessions = totalSessions {
    _roomCode = roomCode ?? '';
  }

  /// Set the room code (used after generating a unique code)
  void setRoomCode(String code) {
    _roomCode = code;
  }

  // Method to update joinedUsers from real-time database
  void updateJoinedUsers(List<String> newUsers) {
    joinedUsers.clear();
    joinedUsers.addAll(newUsers);
  }

  // Method to start listening to joined users changes
  Stream<List<String>> listenToJoinedUsers() {
    return FirebaseDatabase.instance
        .ref(FirebaseConstants.getRoomUsersPath(_roomCode))
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return <String>[];

          final Map<dynamic, dynamic> usersMap =
              event.snapshot.value as Map<dynamic, dynamic>;

          final List<String> onlineUsers = <String>[];
          const int gracePeriodMinutes = 1; // 5 minutes grace period
          const int gracePeriodMs = gracePeriodMinutes * 60 * 1000;
          final int currentTime = DateTime.now().millisecondsSinceEpoch;

          usersMap.forEach((userId, userData) {
            if (userData is Map) {
              final bool isOnline = userData['online'] ?? false;
              final int lastSeen = userData['lastSeen'] ?? 0;

              // Include user if they are online OR if they went offline within grace period
              if (isOnline || (currentTime - lastSeen) < gracePeriodMs) {
                onlineUsers.add(userId.toString());
              }
            } else {
              // Handle legacy data structure (just boolean)
              if (userData == true) {
                onlineUsers.add(userId.toString());
              }
            }
          });

          return onlineUsers;
        });
  }

  /// Check if this room has finished all its sessions
  bool get isFinished {
    final now = DateTime.now().toUtc(); // Use UTC for consistency
    final createdAtDate = _createdAt.toDate().toUtc(); // Convert to UTC
    final elapsed = now.difference(createdAtDate);
    final elapsedMinutes = elapsed.inMinutes;

    final fullCycle = _workDuration + _breakDuration;
    final cyclesPassed = elapsedMinutes ~/ fullCycle;

    // Calculate current session (1-based)
    final session = cyclesPassed + 1;

    // Room is finished if current session exceeds total sessions
    return session > _totalSessions;
  }

  /// Get the current session number for this room
  int get currentSession {
    final now = DateTime.now().toUtc(); // Use UTC for consistency
    final createdAtDate = _createdAt.toDate().toUtc(); // Convert to UTC
    final elapsed = now.difference(createdAtDate);
    final elapsedMinutes = elapsed.inMinutes;

    final fullCycle = _workDuration + _breakDuration;
    final cyclesPassed = elapsedMinutes ~/ fullCycle;

    // Calculate current session (1-based)
    final session = cyclesPassed + 1;

    // Return the current session, capped at total sessions
    return session > _totalSessions ? _totalSessions : session;
  }

  factory PomodoroRoom.fromRealtimeMap(Map<dynamic, dynamic> data) {
    // Handle joinedUsers - it can be either a list or a map
    List<String> joinedUsers = [];
    if (data['users'] != null) {
      // If users is a map, extract the keys (user IDs)
      final Map<dynamic, dynamic> usersMap =
          data['users'] as Map<dynamic, dynamic>;
      joinedUsers = usersMap.keys.map((key) => key.toString()).toList();
    }

    return PomodoroRoom(
      roomCode: data['roomCode'] ?? '',
      creatorId: data['creatorId'] ?? '',
      createdAt: Timestamp.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      availableRoom: data['availableRoom'] ?? true,
      name: data['name'] ?? '',
      capacity: data['capacity'] ?? 0,
      workDuration: data['workDuration'] ?? 25,
      breakDuration: data['breakDuration'] ?? 5,
      isPublic: data['Public'] ?? true,
      totalSessions: data['numberOfSessions'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      joinedUsers: joinedUsers,
      isScheduled: data['isScheduled'] ?? false,
      scheduleTime: Timestamp.fromMillisecondsSinceEpoch(
        data['scheduleTime'] ?? 0,
      ),
    );
  }

  factory PomodoroRoom.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PomodoroRoom(
      roomCode: doc.id,
      creatorId: data['creatorId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      availableRoom: data['availableRoom'] ?? true,
      name: data['name'] ?? '',
      capacity: data['capacity'] ?? 0,
      workDuration: data['workDuration'] ?? 25,
      breakDuration: data['breakDuration'] ?? 5,
      isPublic: data['Public'] ?? true,
      totalSessions: data['numberOfSessions'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      joinedUsers: List<String>.from(data['joinedUsers'] ?? []),
      isScheduled: data['isScheduled'] ?? false,
      scheduleTime: data['scheduleTime'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomCode': _roomCode,
      'creatorId': _creatorId,
      'createdAt': _createdAt,
      'availableRoom': _availableRoom,
      'name': _name,
      'capacity': _capacity,
      'workDuration': _workDuration,
      'breakDuration': _breakDuration,
      'Public': isPublic,
      'numberOfSessions': _totalSessions,
      'tags': tags,
      'joinedUsers': joinedUsers,
    };
  }

  Map<String, dynamic> toMapRealTimeDB() {
    return {
      'roomCode': _roomCode,
      'creatorId': _creatorId,
      'createdAt': _createdAt.millisecondsSinceEpoch,
      'availableRoom': _availableRoom,
      'name': _name,
      'capacity': _capacity,
      'workDuration': _workDuration,
      'breakDuration': _breakDuration,
      'Public': isPublic,
      'numberOfSessions': _totalSessions,
      'tags': tags,
      'joinedUsers': joinedUsers,
      'isScheduled': isScheduled,
      'scheduleTime': scheduleTime.millisecondsSinceEpoch,
    };
  }

  // Getters
  String get roomCode => _roomCode;
  String get creatorId => _creatorId;
  Timestamp get createdAt => _createdAt;
  bool get availableRoom => _availableRoom;
  String get name => _name;
  int get capacity => _capacity;
  int get workDuration => _workDuration;
  int get breakDuration => _breakDuration;
  int get totalSessions => _totalSessions;

  // Setters
  set availableRoom(bool value) => _availableRoom = value;
  set name(String value) => _name = value;
  set capacity(int value) => _capacity = value;
  set workDuration(int value) => _workDuration = value;
  set breakDuration(int value) => _breakDuration = value;
  set totalSessions(int value) => _totalSessions = value;
}



///
 ///
 /// the break sessions= totalSessions - 1
 // so end date should be the createdAt + (totalSessions * workDuration) + (totalSessions - 1) * breakDuration

 // for example if we have 2 sessions of 10 mins , and it started at 7:00 :D
 // the end date should be 7:00 + (2*10) + (1*5) = 7:25 exactly  :D

 // given that someone entered at 7:10 , we need to know the following
 //what phase now we are in
 // when exactly are we in the phase
 // and how many sessions we passed

 // 7:30 - 7:10 = 20 mins
 // 20 mins=  1 work session ( 10 mins ) + 1 break session ( 5 mins )
 //and we are in the second work phase now and remaining time is 10 min

 // we need an equation to get these info
 // elapsedTime = currentTime - createdAt
 // fullcycle= workduration + breakDuration
 // NumberOfCyclesPassed = elapsedTime / fullcycle

 //elapsedTime = 20 mins
 // fullcycle = 10 + 5 = 15
 // NumberOfCyclesPassed = 20 / 15 = 1.33 = 1
 // so we passed 1 cylce ( 1 work phase and 1 break phase )
 // now we need to know the remaining time
 // remainingTime = elapsedTime - (NumberOfCyclesPassed * fullcycle)
 // remainingTime = 20 - (1 * 15) = 5
 // or , remainingTime = elapsedTime % fullcycle :D :D :D
 // remainingTime = 20 % 15 = 5

 // now we need to know the current phase
 // if remainingTime < workDuration then we are in the work phase
 // and we will handle and make sure that workduration is always more than breakDuration
 // else we are in the break phase
 // so we are in the work phase now
 // and the remaining time is 5 mins

 // another example , we are at 7:23,
 // but instead we have 3 sessions , meaning we should end at 7:40 ( 7:00 + (3*10) + (2*5) = 7:40)
 // so the elapsed time is 7:23 - 7:00 = 23 mins
 // fullcycle = 10 + 5 = 15
 // NumberOfCyclesPassed = 23 / 15 = 1.53 = 1
 // remainingTime for the current phase ( work phase ) = 23 - (1 * 15) = 8
 // or remainingTime = 23 % 15 = 8
 // so we are in the work phase now for 8 mins
 // and the remaining time is 2 mins for this phase 