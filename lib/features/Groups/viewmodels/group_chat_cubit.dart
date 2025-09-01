import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/group_message.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/services/group_chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// States
abstract class GroupChatState {}

class GroupChatInitialState extends GroupChatState {}

class GroupChatLoadingState extends GroupChatState {}

class GroupChatLoadedState extends GroupChatState {
  final List<GroupMessage> messages;
  final List<Map<String, dynamic>> members;
  final bool isSending;

  GroupChatLoadedState({
    required this.messages,
    required this.members,
    this.isSending = false,
  });
}

class GroupChatErrorState extends GroupChatState {
  final String error;
  GroupChatErrorState(this.error);
}

// Cubit
class GroupChatCubit extends Cubit<GroupChatState> {
  final GroupChatService _chatService = GroupChatService();
  StreamSubscription<List<GroupMessage>>? _messagesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _membersSubscription;
  String? _currentGroupId;
  List<GroupMessage> _currentMessages = [];
  List<Map<String, dynamic>> _currentMembers = [];

  GroupChatCubit() : super(GroupChatInitialState());

  /// Start listening to group chat messages
  void startListeningToChat(String groupId) {
    _currentGroupId = groupId;
    _stopListeningToChat(); // Stop any existing subscription

    emit(GroupChatLoadingState());

    // Listen to messages (real-time stream like room chat)
    _messagesSubscription = _chatService
        .getGroupMessages(groupId)
        .listen(
          (messages) {
            _currentMessages = messages;
            // If we have members, emit the loaded state
            if (_currentMembers.isNotEmpty) {
              emit(
                GroupChatLoadedState(
                  messages: messages,
                  members: _currentMembers,
                ),
              );
            }
          },
          onError: (error) {
            emit(GroupChatErrorState(error.toString()));
          },
        );

    // Listen to members
    _membersSubscription = _chatService
        .getGroupMembers(groupId)
        .listen(
          (members) {
            _currentMembers = members;
            // If we have messages, emit the loaded state
            if (_currentMessages.isNotEmpty) {
              emit(
                GroupChatLoadedState(
                  messages: _currentMessages,
                  members: members,
                ),
              );
            }
          },
          onError: (error) {
            emit(GroupChatErrorState(error.toString()));
          },
        );
  }

  /// Stop listening to chat messages
  void _stopListeningToChat() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _membersSubscription?.cancel();
    _membersSubscription = null;
  }

  /// Send a message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || _currentGroupId == null) return;

    // Show sending state while keeping messages visible
    if (state is GroupChatLoadedState) {
      final currentState = state as GroupChatLoadedState;
      emit(
        GroupChatLoadedState(
          messages: currentState.messages,
          members: currentState.members,
          isSending: true,
        ),
      );
    }

    try {
      await _chatService.sendMessage(
        groupId: _currentGroupId!,
        message: message.trim(),
      );
      // Message will be added to the stream automatically, no need to emit new state
    } catch (e) {
      // If error, revert to normal state
      if (state is GroupChatLoadedState) {
        final currentState = state as GroupChatLoadedState;
        emit(
          GroupChatLoadedState(
            messages: currentState.messages,
            members: currentState.members,
            isSending: false,
          ),
        );
      }
      emit(GroupChatErrorState('Error sending message: $e'));
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    if (_currentGroupId == null) return;

    try {
      await _chatService.deleteMessage(_currentGroupId!, messageId);
      // Message will be removed from the stream automatically
    } catch (e) {
      emit(GroupChatErrorState('Error deleting message: $e'));
    }
  }

  /// Toggle a reaction on a message
  Future<void> toggleReaction(String messageId, String emoji) async {
    if (_currentGroupId == null) return;

    try {
      // Get current message to check existing reactions
      final currentMessages =
          state is GroupChatLoadedState
              ? (state as GroupChatLoadedState).messages
              : [];

      final message = currentMessages.firstWhere(
        (msg) => msg.id == messageId,
        orElse: () => throw Exception('Message not found'),
      );

      final currentReactions = Map<String, List<String>>.from(
        (message.reactions as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            ) ??
            {},
      );

      // Get current user ID
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final newReactions = <String, List<String>>{};

      // Check if user already reacted with this emoji
      bool userHasReacted = false;
      for (final entry in currentReactions.entries) {
        if (entry.key == emoji) {
          if (entry.value.contains(currentUserId)) {
            // Remove reaction from this emoji
            final newList = List<String>.from(entry.value)
              ..remove(currentUserId);
            if (newList.isNotEmpty) {
              newReactions[emoji] = newList;
            }
            userHasReacted = true;
          } else {
            // Add reaction to this emoji (keep existing users)
            final newList = List<String>.from(entry.value)..add(currentUserId);
            newReactions[emoji] = newList;
            userHasReacted = true;
          }
        } else {
          // Keep other emoji reactions but remove this user
          final newList = List<String>.from(entry.value)..remove(currentUserId);
          if (newList.isNotEmpty) {
            newReactions[entry.key] = newList;
          }
        }
      }

      // If user hasn't reacted with this emoji yet, add it
      if (!userHasReacted) {
        newReactions[emoji] = [currentUserId];
      }

      await _chatService.updateMessageReactions(
        _currentGroupId!,
        messageId,
        newReactions,
      );
      // Messages will automatically update via stream
    } catch (e) {
      emit(GroupChatErrorState('Error toggling reaction: $e'));
    }
  }

  /// Send a reply message
  Future<void> sendReplyMessage({
    required String message,
    required String replyToMessageId,
    required String replyToMessageContent,
    required String replyToSenderName,
  }) async {
    if (message.trim().isEmpty || _currentGroupId == null) return;

    try {
      await _chatService.sendReplyMessage(
        groupId: _currentGroupId!,
        message: message.trim(),
        replyToMessageId: replyToMessageId,
        replyToMessageContent: replyToMessageContent,
        replyToSenderName: replyToSenderName,
      );
      // Message will be added to the stream automatically
    } catch (e) {
      emit(GroupChatErrorState('Error sending reply: $e'));
    }
  }

  /// Clear error state
  void clearError() {
    emit(GroupChatInitialState());
  }

  /// Reset cubit state and clear cached data
  void reset() {
    _stopListeningToChat();
    _currentGroupId = null;
    _currentMessages = [];
    _currentMembers = [];
    emit(GroupChatInitialState());
  }

  @override
  Future<void> close() {
    _stopListeningToChat();
    return super.close();
  }
}
