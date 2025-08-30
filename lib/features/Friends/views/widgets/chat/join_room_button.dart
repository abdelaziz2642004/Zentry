import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/room_invitation_utils.dart';

class JoinRoomButton extends StatelessWidget {
  final bool isMe;
  final VoidCallback onJoinRoom;

  const JoinRoomButton({
    super.key,
    required this.isMe,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onJoinRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: RoomInvitationUtils.getJoinButtonBackgroundColor(
            isMe,
          ),
          foregroundColor: RoomInvitationUtils.getJoinButtonTextColor(isMe),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          RoomInvitationUtils.getJoinButtonText(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
