import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/chat_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/reaction_result.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService = ChatService();
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _conversationsSubscription;

  ChatCubit() : super(ChatInitialState());

  /// Load chat messages with a specific user
  void loadChatMessages(String otherUserId) {
    // Cancel previous subscription if exists
    _messagesSubscription?.cancel();

    // Only emit if not closed
    if (!isClosed) {
      emit(ChatLoadingState());
    }

    _messagesSubscription = _chatService
        .getChatMessages(otherUserId)
        .listen(
          (messages) {
            if (!isClosed) {
              emit(MessagesLoadedState(messages));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(ChatErrorState(error.toString()));
            }
          },
        );
  }

  /// Load all chat conversations
  void loadConversations() {
    // Cancel previous subscription if exists
    _conversationsSubscription?.cancel();

    // Only emit if not closed
    if (!isClosed) {
      emit(ChatLoadingState());
    }

    _conversationsSubscription = _chatService.getChatConversations().listen(
      (conversations) {
        if (!isClosed) {
          emit(ConversationsLoadedState(conversations));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(ChatErrorState(error.toString()));
        }
      },
    );
  }

  /// Send a text message
  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String content,
  }) async {
    try {
      await _chatService.sendMessage(
        receiverId: receiverId,
        receiverName: receiverName,
        content: content,
      );
      // Messages will automatically update via stream, no need to reload
    } on Exception catch (e) {
      print('Sending message to: $receiverId');

      if (!isClosed) {
        emit(ChatErrorState(e.toString()));
      }
    }
  }

  /// Send a room invitation
  Future<void> sendRoomInvitation({
    required String receiverId,
    required String receiverName,
    required String roomCode,
    required String roomName,
    String? message,
  }) async {
    try {
      await _chatService.sendRoomInvitation(
        receiverId: receiverId,
        receiverName: receiverName,
        roomCode: roomCode,
        roomName: roomName,
        message: message,
      );
      if (!isClosed) {
        emit(RoomInvitationSentState());
      }
    } catch (e) {
      if (!isClosed) {
        emit(ChatErrorState(e.toString()));
      }
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      await _chatService.markMessagesAsRead(otherUserId);
    } catch (e) {
      if (!isClosed) {
        emit(ChatErrorState(e.toString()));
      }
    }
  }

  /// Clear error
  void clearError() {
    if (!isClosed) {
      emit(ChatInitialState());
    }
  }

  /// Reset cubit state and clear cached data
  void reset() {
    stopStreams();
    if (!isClosed) {
      emit(ChatInitialState());
    }
  }

  /// Stop all streams
  void stopStreams() {
    _messagesSubscription?.cancel();
    _conversationsSubscription?.cancel();
  }

  /// Get total unread count stream
  Stream<int> getTotalUnreadCount() {
    return _chatService.getTotalUnreadCount();
  }

  /// Get unread count for specific user stream
  Stream<int> getUnreadCountForUser(String userId) {
    return _chatService.getUnreadCountForUser(userId);
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      // Messages will automatically update via stream, no need to reload
    } catch (e) {
      if (!isClosed) {
        emit(ChatErrorState(e.toString()));
      }
    }
  }

  /// Toggle a reaction on a message
  Future<void> toggleReaction(String messageId, String emoji) async {
    try {
      final result = await _chatService.toggleReaction(messageId, emoji);
      if (result == ReactionResult.blocked) {
        // Show blocking message
        if (!isClosed) {
          emit(
            ReactionBlockedState(
              'Cannot react to message - user is blocked or has blocked you',
            ),
          );
        }
        return;
      } else if (result == ReactionResult.notFriends) {
        // Show not friends message
        if (!isClosed) {
          emit(
            ReactionBlockedState(
              'Cannot react to message - users are not friends',
            ),
          );
        }
        return;
      }
      // Messages will automatically update via stream, no need to reload
    } catch (e) {
      if (!isClosed) {
        emit(ChatErrorState(e.toString()));
      }
    }
  }

  /// Send a reply message
  Future<void> sendReplyMessage({
    required String receiverId,
    required String receiverName,
    required String content,
    required String replyToMessageId,
    required String replyToMessageContent,
    required String replyToSenderName,
  }) async {
    try {
      await _chatService.sendReplyMessage(
        receiverId: receiverId,
        receiverName: receiverName,
        content: content,
        replyToMessageId: replyToMessageId,
        replyToMessageContent: replyToMessageContent,
        replyToSenderName: replyToSenderName,
      );
      // Messages will automatically update via stream, no need to reload
    } catch (e) {
      if (!isClosed) {
        emit(ChatErrorState(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    stopStreams();
    return super.close();
  }
}
