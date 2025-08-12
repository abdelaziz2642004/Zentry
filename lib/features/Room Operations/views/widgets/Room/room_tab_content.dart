import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/joined_users_part.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/room_details_timer.dart';

class RoomTabContent extends StatelessWidget {
  final String roomCode;

  const RoomTabContent({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Room Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const RoomDetailsAndTimer(),

          const SizedBox(height: 16),
          const Text(
            "Users in Room",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Joineduserspart(roomCode: roomCode),
        ],
      ),
    );
  }
}
