import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/chat_repository.dart';

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit(this.chatRepository) : super(ChatInitialState());

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
      // Message will be removed from the stream automatically
    } on Exception catch (e) {
      e;
      emit(ChatErrorState('Error deleting message: $e'));
    }
  }

  @override
  Future<void> close() {
    _stopListeningToChat();
    return super.close();
  }
}
