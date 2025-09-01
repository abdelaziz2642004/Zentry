import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_chat.dart';

class ChatTabContent extends StatelessWidget {
  final String roomCode;
  final FireUser? currentUser;

  const ChatTabContent({
    super.key,
    required this.roomCode,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoomChatCubit>(
      create:
          (context) =>
              RoomChatCubit(context.read<RoomChatCubit>().chatRepository),
      child:
          currentUser != null
              ? RoomChat(roomCode: roomCode, currentUser: currentUser!)
              : const Center(child: Text('Please log in to use chat')),
    );
  }
}
