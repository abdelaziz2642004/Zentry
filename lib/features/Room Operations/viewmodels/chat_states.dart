import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/chat_message.dart';

abstract class ChatStates {}

class ChatInitialState extends ChatStates {}

class ChatLoadingState extends ChatStates {}

class ChatMessagesLoaded extends ChatStates {
  final List<ChatMessage> messages;

  ChatMessagesLoaded(this.messages);
}

class ChatErrorState extends ChatStates {
  final String error;

  ChatErrorState(this.error);
}

class ChatMessageSent extends ChatStates {}

class ChatMessageDeleted extends ChatStates {}
