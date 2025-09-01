import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';

abstract class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatErrorState extends ChatState {
  final String error;
  ChatErrorState(this.error);
}

class MessagesLoadedState extends ChatState {
  final List<ChatMessage> messages;
  MessagesLoadedState(this.messages);
}

class RoomInvitationSentState extends ChatState {}

class ConversationsLoadedState extends ChatState {
  final List<Map<String, dynamic>> conversations;
  ConversationsLoadedState(this.conversations);
}
