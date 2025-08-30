import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/conversation_tile.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/empty_conversations_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatCubit _chatCubit;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _chatCubit = BlocProvider.of<ChatCubit>(context);
    _chatCubit.loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          buildWhen:
              (previous, current) =>
                  current is ChatLoadingState ||
                  current is ConversationsLoadedState ||
                  current is ChatErrorState,
          builder: (context, state) {
            if (state is ChatLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ConversationsLoadedState) {
              if (state.conversations.isEmpty) {
                return const EmptyConversationsWidget();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _chatCubit.loadConversations();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = state.conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      userService: _userService,
                    );
                  },
                ),
              );
            } else if (state is ChatErrorState) {
              return Center(child: Text(state.error));
            }

            return const Center(child: Text(''));
          },
        ),
      ),
    );
  }
}
