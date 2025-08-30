import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/group_message.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/group_chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_message_bubble.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/view_profile_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final StudyGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
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
    _messageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              '${widget.group.memberCount} members',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showGroupInfo();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // Group info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey[50],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        widget.group.imageUrl.isNotEmpty
                            ? NetworkImage(widget.group.imageUrl)
                            : null,
                    child:
                        widget.group.imageUrl.isEmpty
                            ? Text(
                              widget.group.name.isNotEmpty
                                  ? widget.group.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.group.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Chat messages area
            Expanded(
              child: BlocConsumer<GroupChatCubit, GroupChatState>(
                listener: (context, state) {
                  if (state is GroupChatLoadedState) {
                    // Auto-scroll to bottom when new messages arrive
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                  }
                },
                builder: (context, state) {
                  if (state is GroupChatLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GroupChatErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error loading messages',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (state is GroupChatLoadedState) {
                    if (state.messages.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isCurrentUser =
                            message.senderId == _getCurrentUserId();

                        return GroupMessageBubble(
                          message: message,
                          isMyMessage: isCurrentUser,
                          onDelete: () {
                            _chatCubit.deleteMessage(message.id);
                          },
                          onReact: (emoji) {
                            _chatCubit.toggleReaction(message.id, emoji);
                          },
                          onReply: (replyToMessage) {
                            setState(() {
                              _replyingTo = replyToMessage;
                            });
                          },
                          onViewProfile: (userId) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ViewProfileScreen(userId: userId),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  return const Center(child: Text('No messages'));
                },
              ),
            ),
            // Message input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Reply preview
                  if (_replyingTo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Replying to ${_replyingTo!.senderName}',
                                  style: TextStyle(
                                    color: mainColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _replyingTo!.message,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _replyingTo = null;
                              });
                            },
                            icon: const Icon(Icons.close, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Message input
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText:
                                  _replyingTo != null
                                      ? 'Reply to message...'
                                      : 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<GroupChatCubit, GroupChatState>(
                          builder: (context, state) {
                            final isLoading =
                                state is GroupChatLoadedState &&
                                state.isSending;
                            return Container(
                              decoration: BoxDecoration(
                                color: mainColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: IconButton(
                                onPressed: isLoading ? null : _sendMessage,
                                icon:
                                    isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentUserId() {
    // Get current user ID from Firebase Auth
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      if (_replyingTo != null) {
        // Send reply message
        _chatCubit.sendReplyMessage(
          message: message,
          replyToMessageId: _replyingTo!.id,
          replyToMessageContent: _replyingTo!.message,
          replyToSenderName: _replyingTo!.senderName,
        );
      } else {
        // Send normal message
        _chatCubit.sendMessage(message);
      }

      _messageController.clear();
      // Clear reply state after sending
      setState(() {
        _replyingTo = null;
      });
    }
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(widget.group.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Created by: ${widget.group.creatorName}'),
                const SizedBox(height: 8),
                Text('Category: ${widget.group.category}'),
                const SizedBox(height: 8),
                Text(
                  'Members: ${widget.group.memberCount}/${widget.group.maxMembers}',
                ),
                const SizedBox(height: 8),
                Text('Type: ${widget.group.isPublic ? "Public" : "Private"}'),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(widget.group.description),
                if (widget.group.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tags:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children:
                        widget.group.tags
                            .map(
                              (tag) => Chip(
                                label: Text('#$tag'),
                                backgroundColor: Colors.grey[200],
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
