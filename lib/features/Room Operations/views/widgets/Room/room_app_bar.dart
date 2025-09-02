import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/room_invitation_button.dart';

class RoomAppBar {
  static AppBar build(String roomCode, BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF05161A),
      foregroundColor: const Color(0xFFD9F5F0),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2CACAD).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.room, color: Color(0xFF75E2E0), size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Room $roomCode',
            style: const TextStyle(
              color: Color(0xFFD9F5F0),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C7075).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0C7075).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Color(0xFF75E2E0)),
          onPressed: () async {
            await leaveroom(context, roomCode);
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2CACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: RoomInvitationButton(
            roomCode: roomCode,
            roomName: 'Study Session',
          ),
        ),
      ],
    );
  }
}

Future<bool> leaveroom(BuildContext context, String roomCode) async {
  // Capture context before async operations
  final currentContext = context;

  // Trigger the same leave confirmation dialog
  final shouldLeave = await showDialog<bool>(
    context: currentContext,
    builder:
        (_) => AlertDialog(
          backgroundColor: const Color(0xFF05161A),
          title: const Text(
            "Leave Room",
            style: TextStyle(
              color: Color(0xFFD9F5F0),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to leave the room?",
            style: TextStyle(color: Color(0xFF75E2E0)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(currentContext, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF6DA5C0)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(currentContext, true);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF0C7075).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Leave",
                style: TextStyle(color: Color(0xFFD9F5F0)),
              ),
            ),
          ],
        ),
  );

  // Check if context is still mounted before using it
  if (!currentContext.mounted) return false;

  if (shouldLeave == true) {
    BlocProvider.of<RoomCubit>(currentContext).leaveRoom(roomCode);
    Navigator.pop(currentContext);
    return true; // Leave the room
    // Navigate back
  }
  return false; // Stay in the room
}
