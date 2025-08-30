import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';

abstract class ChatInputState {}

class ChatInputInitial extends ChatInputState {}

class ChatInputSendingMessage extends ChatInputState {
  final String message;
  final ChatMessage? replyTo;

  ChatInputSendingMessage({required this.message, this.replyTo});
}

class ChatInputSendingFriendRequest extends ChatInputState {}

class ChatInputAcceptingFriendRequest extends ChatInputState {}

class ChatInputRejectingFriendRequest extends ChatInputState {}

class ChatInputMessageSent extends ChatInputState {
  final String message;
  final ChatMessage? replyTo;

  ChatInputMessageSent({required this.message, this.replyTo});
}

class ChatInputFriendRequestSent extends ChatInputState {}

class ChatInputFriendRequestAccepted extends ChatInputState {}

class ChatInputFriendRequestRejected extends ChatInputState {}

class ChatInputError extends ChatInputState {
  final String error;
  final ChatInputState? previousState;

  ChatInputError({required this.error, this.previousState});
}
