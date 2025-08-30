import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';

class RoomJoiningUtils {
  /// Validates if a room invitation can be joined
  static bool canJoinRoom(ChatMessage message, RoomCubit roomCubit) {
    // Check if message is a valid room invitation
    if (!_isValidRoomInvitation(message)) {
      return false;
    }

    // Check if already joining a room
    final currentState = roomCubit.state;
    if (currentState.runtimeType.toString() == 'RoomJoinLoadingState') {
      return false;
    }

    return true;
  }

  /// Gets room code from invitation message
  static String? getRoomCode(ChatMessage message) {
    if (_isValidRoomInvitation(message)) {
      return message.roomCode;
    }
    return null;
  }

  /// Validates room invitation message
  static bool _isValidRoomInvitation(ChatMessage message) {
    return message.type == MessageType.roomInvitation &&
        message.roomCode != null &&
        message.roomCode!.isNotEmpty;
  }

  /// Gets error message for room joining issues
  static String getRoomJoiningErrorMessage(
    ChatMessage message,
    RoomCubit roomCubit,
  ) {
    if (!_isValidRoomInvitation(message)) {
      return 'Invalid room invitation';
    }

    final currentState = roomCubit.state;
    if (currentState.runtimeType.toString() == 'RoomJoinLoadingState') {
      return 'Already joining a room. Please wait.';
    }

    return 'Failed to join room';
  }

  /// Shows room joining loading indicator
  static void showJoiningIndicator(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Joining room...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows room joining error
  static void showJoiningError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(failedSnackBar(msg: error));
  }

  /// Navigates to room screen
  static void navigateToRoom(
    BuildContext context,
    String roomCode,
    RoomCubit roomCubit,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: roomCubit,
              child: RoomScreen(roomCode: roomCode),
            ),
      ),
    );
  }
}
