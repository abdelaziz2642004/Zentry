import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/chat_repository.dart';

class RoomChatCubit extends Cubit<ChatStates> {
  RoomChatCubit(this.chatRepository) : super(ChatInitialState());

  final ChatRepository chatRepository;
  StreamSubscription<List<ChatMessage>>? _chatSubscription;
  String? _currentRoomCode;

  // Start listening to chat messages
  void startListeningToChat(String roomCode) {
    _currentRoomCode = roomCode;
    _stopListeningToChat(); // Stop any existing subscription

    emit(ChatLoadingState());

    _chatSubscription = chatRepository
        .listenToChat(roomCode)
        .listen(
          (messages) {
            emit(ChatMessagesLoaded(messages));
          },
          onError: (error) {
            emit(ChatErrorState('Error loading messages: $error'));
          },
        );
  }

  // Stop listening to chat messages
  void _stopListeningToChat() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  // Send a text message
  Future<void> sendMessage(String message, FireUser currentUser) async {
    if (message.trim().isEmpty || _currentRoomCode == null) return;

    final chatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      message: message.trim(),
      timestamp: Timestamp.now(),
      type: MessageType.text,
      senderName: currentUser.fullName,
    );

    try {
      await chatRepository.sendMessage(_currentRoomCode!, chatMessage);
      // Message will be added to the stream automatically
    } on Exception catch (e) {
      e;
      emit(ChatErrorState('Error sending message: $e'));
    }
  }

  // Send system message (user joined/left)
  Future<void> sendSystemMessage(String message) async {
    if (_currentRoomCode == null) return;

    try {
      await chatRepository.sendSystemMessage(_currentRoomCode!, message);
    } on Exception catch (e) {
      e;
      emit(ChatErrorState('Error sending system message: $e'));
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    if (_currentRoomCode == null) return;

    try {
      await chatRepository.deleteMessage(_currentRoomCode!, messageId);
      // Messages will automatically update via stream
    } catch (e) {
      emit(ChatErrorState('Error deleting message: $e'));
    }
  }

  // Toggle a reaction on a message
  Future<void> toggleReaction(String messageId, String emoji) async {
    if (_currentRoomCode == null) return;

    try {
      // Get current message to check existing reactions
      final currentMessages =
          state is ChatMessagesLoaded
              ? (state as ChatMessagesLoaded).messages
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
            // Remove reaction
            final newList = List<String>.from(entry.value)
              ..remove(currentUserId);
            if (newList.isNotEmpty) {
              newReactions[emoji] = newList;
            }
            userHasReacted = true;
          } else {
            // Add reaction (but first remove from others)
            newReactions[emoji] = [currentUserId];
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

      await chatRepository.updateMessageReactions(
        _currentRoomCode!,
        messageId,
        newReactions,
      );
      // Messages will automatically update via stream
    } catch (e) {
      emit(ChatErrorState('Error toggling reaction: $e'));
    }
  }

  @override
  Future<void> close() {
    _stopListeningToChat();
    return super.close();
  }
}
