import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_messages_list.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_input.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_options_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _chatCubit;
  final BlockService _blockService = BlockService();
  final FriendsService _friendsService = FriendsService();
  bool _isBlocked = false;
  bool _isBlockedByUser = false;
  bool _isFriend = false;
  bool _isLoadingFriendship = true;
  bool _isFriendRequestPending = false;
  bool _isFriendRequestReceived = false;
  bool _isAnyRequestPending = false;
  bool _disposed = false;
  StreamSubscription<bool>? _blockStatusSubscription;
  StreamSubscription<bool>? _blockedByUserSubscription;
  StreamSubscription<Map<String, dynamic>>? _friendshipStatusSubscription;
  ChatMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    _chatCubit = BlocProvider.of<ChatCubit>(context);
    _chatCubit.loadChatMessages(widget.otherUserId);
    _chatCubit.markMessagesAsRead(widget.otherUserId);
    _setupBlockStatusStreams();
    _setupFriendshipStatusStream();
  }

  @override
  void dispose() {
    _disposed = true;
    _blockStatusSubscription?.cancel();
    _blockedByUserSubscription?.cancel();
    _friendshipStatusSubscription?.cancel();
    _scrollController.dispose();
    _chatCubit.stopStreams();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05161A),
      appBar: ChatAppBar(
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
        onMorePressed: _showChatOptions,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessagesList(
              otherUserId: widget.otherUserId,
              otherUserName: widget.otherUserName,
              scrollController: _scrollController,
              onScrollToBottom: _scrollToBottom,
              isBlocked: _isBlocked,
              isBlockedByUser: _isBlockedByUser,
              isFriend: _isFriend,
              isAnyRequestPending: _isAnyRequestPending,
              onReplyStateChanged: (replyToMessage) {
                setState(() {
                  _replyingTo = replyToMessage;
                });
              },
            ),
          ),
          _isLoadingFriendship
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF05161A).withOpacity(0.9),
                      const Color(0xFF072E33).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                    ),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2CACAD),
                    ),
                  ),
                ),
              )
              : ChatInput(
                otherUserId: widget.otherUserId,
                otherUserName: widget.otherUserName,
                isBlocked: _isBlocked,
                isBlockedByUser: _isBlockedByUser,
                isFriend: _isFriend,
                isFriendRequestPending: _isFriendRequestPending,
                isFriendRequestReceived: _isFriendRequestReceived,
                isAnyRequestPending: _isAnyRequestPending,
                onRefreshFriendshipStatus: _refreshFriendshipStatus,
                replyingTo: _replyingTo,
                onClearReply: () {
                  setState(() {
                    _replyingTo = null;
                  });
                },
              ),
        ],
      ),
    );
  }

  void _setupBlockStatusStreams() {
    // Listen to real-time block status changes
    _blockStatusSubscription = _blockService
        .isUserBlockedStream(widget.otherUserId)
        .listen((isBlocked) {
          if (!_disposed && mounted) {
            setState(() {
              _isBlocked = isBlocked;
            });
          }
        });

    _blockedByUserSubscription = _blockService
        .isBlockedByUserStream(widget.otherUserId)
        .listen((isBlockedByUser) {
          if (!_disposed && mounted) {
            setState(() {
              _isBlockedByUser = isBlockedByUser;
            });
          }
        });
  }

  void _setupFriendshipStatusStream() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    // Listen to real-time detailed friendship status changes
    _friendshipStatusSubscription = _friendsService
        .getDetailedFriendshipStatusStream(currentUserId, widget.otherUserId)
        .listen((status) {
          if (!_disposed && mounted) {
            setState(() {
              _isFriend = status['isFriend'] ?? false;
              _isAnyRequestPending = status['hasPendingRequest'] ?? false;
              _isFriendRequestPending = status['isRequestSent'] ?? false;
              _isFriendRequestReceived = status['isRequestReceived'] ?? false;
              _isLoadingFriendship = false;
            });
          }
        });
  }

  Future<void> _refreshFriendshipStatus() async {
    // The real-time stream will automatically update the status
    // No need to manually refresh since we're using real-time streams
  }

  void _showChatOptions() {
    showDialog(
      context: context,
      builder:
          (context) => ChatOptionsDialog(
            otherUserId: widget.otherUserId,
            isBlocked: _isBlocked,
            onRefreshFriendshipStatus: _refreshFriendshipStatus,
          ),
    );
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
}
