import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/group_message.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/group_chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_chat/group_chat_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_chat/group_info_banner.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_chat/group_messages_list.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_chat/group_message_input.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_chat/group_info_dialog.dart';

class GroupChatScreen extends StatefulWidget {
  final StudyGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late GroupChatCubit _chatCubit;
  GroupMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    _chatCubit = BlocProvider.of<GroupChatCubit>(context);
    _chatCubit.startListeningToChat(widget.group.id);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => GroupInfoDialog(group: widget.group),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GroupChatAppBar(
        group: widget.group,
        onShowGroupInfo: _showGroupInfo,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            GroupInfoBanner(group: widget.group),
            Expanded(
              child: GroupMessagesList(
                scrollController: _scrollController,
                currentUserId: _getCurrentUserId(),
                onScrollToBottom: _scrollToBottom,
                onReply: (message) {
                  setState(() {
                    _replyingTo = message;
                  });
                },
              ),
            ),
            GroupMessageInput(
              replyingTo: _replyingTo,
              onReplyCleared: _clearReply,
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
