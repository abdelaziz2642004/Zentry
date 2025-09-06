import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';

import '../services/room_service.dart';

class RoomRepository {
  final RoomService _roomService;

  RoomRepository(this._roomService);

  Future<void> createRoom(PomodoroRoom room) async {
    return await _roomService.createRoom(room);
  }

  Future<PomodoroRoom?> joinRoom(String roomcode) async {
    return await _roomService.joinRoom(roomcode);
  }

  Future<void> leaveRoom(String roomCode) async {
    return await _roomService.leaveRoom(roomCode);
  }

  Future<PomodoroRoom?> recentlyFetch() async {
    return await _roomService.recentlyFetch();
  }

  Future<String?> joinedRoomFetch() async {
    return await _roomService.joinedRoomFetch();
  }

  /// Fetch all public rooms from Firestore
  Future<List<PomodoroRoom>> fetchAllPublicRooms() async {
    return await _roomService.fetchAllPublicRooms();
  }

  /// Stream of all public rooms from Firestore
  Stream<List<PomodoroRoom>> streamPublicRooms() {
    return _roomService.streamPublicRooms();
  }
}
