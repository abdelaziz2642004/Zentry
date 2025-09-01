import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/room_invitation_button.dart';

class RoomAppBar {
  static AppBar build(String roomCode, BuildContext context) {
    return AppBar(
      title: Text('Room $roomCode'),
      leading: IconButton(
        icon: const Icon(Icons.exit_to_app), // Custom "Leave Room" icon
        onPressed: () async {
          await leaveroom(context, roomCode);
        },
      ),
      actions: [
        RoomInvitationButton(roomCode: roomCode, roomName: 'Study Session'),
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
          title: const Text("Leave Room"),
          content: const Text("Are you sure you want to leave the room?"),
          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator.pop(currentContext, false), // Stay in the room
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(currentContext, true); // Confirm leaving
              },
              child: const Text("Leave"),
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
