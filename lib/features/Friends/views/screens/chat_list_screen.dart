import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/conversation_tile.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/empty_states/empty_conversations_widget.dart';

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
      backgroundColor: const Color(0xFF05161A),
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFFD9F5F0),
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF02364A).withOpacity(0.95),
                const Color(0xFF024D60).withOpacity(0.9),
                const Color(0xFF0C7075).withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02364A).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD9F5F0)),
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(color: Color(0xFFD9F5F0)),
                ),
                backgroundColor: const Color(0xFF072E33),
              ),
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
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2CACAD)),
                ),
              );
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
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(color: Color(0xFFD9F5F0)),
                ),
              );
            }

            return const Center(
              child: Text('', style: TextStyle(color: Color(0xFFD9F5F0))),
            );
          },
        ),
      ),
    );
  }
}
