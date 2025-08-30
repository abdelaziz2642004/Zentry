import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_input_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/friend_request_handler.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_input_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/error_message_utils.dart';

class ChatInputCubit extends Cubit<ChatInputState> {
  final ChatCubit _chatCubit;
  final FriendRequestHandler _requestHandler = FriendRequestHandler();

  ChatInputCubit(this._chatCubit) : super(ChatInputInitial());

  /// Send a message
  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String content,
    ChatMessage? replyTo,
  }) async {
    final validationError = ChatInputUtils.validateMessage(content);
    if (validationError != null) {
      emit(ChatInputError(error: validationError, previousState: state));
      return;
    }

    final formattedMessage = ChatInputUtils.formatMessage(content);

    emit(ChatInputSendingMessage(message: formattedMessage, replyTo: replyTo));

    try {
      if (replyTo != null) {
        // Send reply message
        _chatCubit.sendReplyMessage(
          receiverId: receiverId,
          receiverName: receiverName,
          content: formattedMessage,
          replyToMessageId: replyTo.id,
          replyToMessageContent: replyTo.content,
          replyToSenderName: replyTo.senderName,
        );
      } else {
        // Send normal message
        _chatCubit.sendMessage(
          receiverId: receiverId,
          receiverName: receiverName,
          content: formattedMessage,
        );
      }

      emit(ChatInputMessageSent(message: formattedMessage, replyTo: replyTo));
    } catch (e) {
      emit(
        ChatInputError(
          error: 'Error sending message: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Send a friend request
  Future<void> sendFriendRequest({
    required String receiverId,
    String message = 'Hi! I\'d like to be your friend.',
  }) async {
    emit(ChatInputSendingFriendRequest());

    try {
      final result = await _requestHandler.sendFriendRequest(
        receiverId,
        message,
      );

      if (result['success']) {
        emit(ChatInputFriendRequestSent());
        // Don't automatically reset - let the UI handle the state transition
        // after the friendship status is refreshed
      } else {
        final formattedError = ErrorMessageUtils.formatFriendRequestError(
          result['error'],
        );
        emit(ChatInputError(error: formattedError, previousState: state));
      }
    } catch (e) {
      emit(
        ChatInputError(
          error: 'Error sending friend request: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(String senderId) async {
    emit(ChatInputAcceptingFriendRequest());

    try {
      final result = await _requestHandler.acceptExistingRequest(senderId);

      if (result['success']) {
        emit(ChatInputFriendRequestAccepted());
        // Don't automatically reset - let the UI handle the state transition
        // after the friendship status is refreshed
      } else {
        emit(ChatInputError(error: result['message'], previousState: state));
      }
    } catch (e) {
      emit(
        ChatInputError(
          error: 'Error accepting friend request: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Reject a friend request
  Future<void> rejectFriendRequest(String senderId) async {
    emit(ChatInputRejectingFriendRequest());

    try {
      final result = await _requestHandler.rejectExistingRequest(senderId);

      if (result['success']) {
        emit(ChatInputFriendRequestRejected());
        // Don't automatically reset - let the UI handle the state transition
        // after the friendship status is refreshed
      } else {
        emit(ChatInputError(error: result['message'], previousState: state));
      }
    } catch (e) {
      emit(
        ChatInputError(
          error: 'Error rejecting friend request: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Reset to initial state
  void reset() {
    emit(ChatInputInitial());
  }

  /// Check if currently sending message
  bool get isSendingMessage => state is ChatInputSendingMessage;

  /// Check if currently sending friend request
  bool get isSendingFriendRequest => state is ChatInputSendingFriendRequest;

  /// Check if currently accepting friend request
  bool get isAcceptingFriendRequest => state is ChatInputAcceptingFriendRequest;

  /// Check if currently rejecting friend request
  bool get isRejectingFriendRequest => state is ChatInputRejectingFriendRequest;

  /// Check if operation was successful
  bool get isSuccess =>
      state is ChatInputMessageSent ||
      state is ChatInputFriendRequestSent ||
      state is ChatInputFriendRequestAccepted ||
      state is ChatInputFriendRequestRejected;

  /// Check if there's an error
  bool get hasError => state is ChatInputError;

  /// Get current error message
  String? get errorMessage {
    if (state is ChatInputError) {
      return (state as ChatInputError).error;
    }
    return null;
  }
}
