import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat_messages_list.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat_input.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat_options_dialog.dart';
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
  ChatMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    _chatCubit = BlocProvider.of<ChatCubit>(context);
    _chatCubit.loadChatMessages(widget.otherUserId);
    _chatCubit.markMessagesAsRead(widget.otherUserId);
    _setupBlockStatusStreams();
    _checkFriendshipStatus();
  }

  @override
  void dispose() {
    _disposed = true;
    _blockStatusSubscription?.cancel();
    _blockedByUserSubscription?.cancel();
    _scrollController.dispose();
    _chatCubit.stopStreams();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: const Center(child: CircularProgressIndicator()),
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
            // Refresh friendship status when block status changes
            _checkFriendshipStatus();
          }
        });

    _blockedByUserSubscription = _blockService
        .isBlockedByUserStream(widget.otherUserId)
        .listen((isBlockedByUser) {
          if (!_disposed && mounted) {
            setState(() {
              _isBlockedByUser = isBlockedByUser;
            });
            // Refresh friendship status when block status changes
            _checkFriendshipStatus();
          }
        });
  }

  Future<void> _checkBlockStatus() async {
    try {
      final isBlocked = await _blockService.isUserBlocked(widget.otherUserId);
      final isBlockedByUser = await _blockService.isBlockedByUser(
        widget.otherUserId,
      );

      if (mounted) {
        setState(() {
          _isBlocked = isBlocked;
          _isBlockedByUser = isBlockedByUser;
        });
      }
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  Future<void> _checkFriendshipStatus() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final isFriend = await _friendsService.checkIfFriends(
        currentUserId,
        widget.otherUserId,
      );
      final isPending = await _friendsService.checkIfFriendRequestSent(
        currentUserId,
        widget.otherUserId,
      );
      final isReceived = await _friendsService.checkIfFriendRequestReceived(
        currentUserId,
        widget.otherUserId,
      );
      final isAnyRequestPending = await _friendsService
          .checkIfAnyFriendRequestPending(currentUserId, widget.otherUserId);

      if (mounted) {
        setState(() {
          _isFriend = isFriend;
          _isFriendRequestPending = isPending;
          _isFriendRequestReceived = isReceived;
          _isAnyRequestPending = isAnyRequestPending;
          _isLoadingFriendship = false;
        });
      }
    } catch (e) {
      print('Error checking friendship status: $e');
      if (mounted) {
        setState(() {
          _isLoadingFriendship = false;
        });
      }
    }
  }

  Future<void> _refreshFriendshipStatus() async {
    await _checkFriendshipStatus();
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
