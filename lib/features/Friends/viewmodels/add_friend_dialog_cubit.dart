import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/add_friend_dialog_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/user_search_handler.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/friendship_checker.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/friend_request_handler.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/error_message_utils.dart';

class AddFriendDialogCubit extends Cubit<AddFriendDialogState> {
  final UserSearchHandler _searchHandler = UserSearchHandler();
  final FriendshipChecker _friendshipChecker = FriendshipChecker();
  final FriendRequestHandler _requestHandler = FriendRequestHandler();

  AddFriendDialogCubit() : super(const AddFriendDialogInitial());

  /// Search for users by friend code
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      emit(
        const AddFriendDialogSearchResults(
          searchResults: [],
          selectedUserId: null,
        ),
      );
      return;
    }

    emit(const AddFriendDialogSearching());

    try {
      final result = await _searchHandler.searchUsersByFriendCode(query);

      if (result['success']) {
        emit(
          AddFriendDialogSearchResults(
            searchResults: result['results'] ?? [],
            selectedUserId: null,
          ),
        );
      } else {
        emit(
          AddFriendDialogError(
            error: result['error'],
            previousState: const AddFriendDialogInitial(),
          ),
        );
      }
    } catch (e) {
      emit(
        AddFriendDialogError(
          error: 'Error searching users: $e',
          previousState: const AddFriendDialogInitial(),
        ),
      );
    }
  }

  /// Select a user and check their friendship status
  Future<void> selectUser(String userId) async {
    final currentState = state;

    if (currentState is AddFriendDialogSearchResults) {
      emit(
        AddFriendDialogCheckingStatus(
          userId: userId,
          searchResults: currentState.searchResults,
        ),
      );

      try {
        final result = await _friendshipChecker.checkFriendshipAndRequestStatus(
          userId,
        );

        if (result['error'] == null) {
          emit(
            AddFriendDialogUserSelected(
              selectedUserId: userId,
              searchResults: currentState.searchResults,
              isAlreadyFriends: result['isAlreadyFriends'] ?? false,
              hasExistingRequest: result['hasExistingRequest'] ?? false,
            ),
          );
        } else {
          emit(
            AddFriendDialogError(
              error: result['error'],
              previousState: currentState,
            ),
          );
        }
      } catch (e) {
        emit(
          AddFriendDialogError(
            error: 'Error checking friendship status: $e',
            previousState: currentState,
          ),
        );
      }
    }
  }

  /// Send a friend request
  Future<void> sendFriendRequest(String message) async {
    final currentState = state;

    if (currentState is AddFriendDialogUserSelected) {
      emit(
        AddFriendDialogSendingRequest(
          selectedUserId: currentState.selectedUserId,
          searchResults: currentState.searchResults,
          isAlreadyFriends: currentState.isAlreadyFriends,
          hasExistingRequest: currentState.hasExistingRequest,
        ),
      );

      try {
        final result = await _requestHandler.sendFriendRequest(
          currentState.selectedUserId,
          message,
        );

        if (result['success']) {
          emit(AddFriendDialogSuccess(message: result['message']));
        } else {
          final formattedError = ErrorMessageUtils.formatFriendRequestError(
            result['error'],
          );
          emit(
            AddFriendDialogError(
              error: formattedError,
              previousState: currentState,
            ),
          );
        }
      } catch (e) {
        emit(
          AddFriendDialogError(
            error: 'Error sending friend request: $e',
            previousState: currentState,
          ),
        );
      }
    }
  }

  /// Accept an existing friend request
  Future<void> acceptExistingRequest() async {
    final currentState = state;

    if (currentState is AddFriendDialogUserSelected) {
      emit(
        AddFriendDialogAcceptingRequest(
          selectedUserId: currentState.selectedUserId,
          searchResults: currentState.searchResults,
        ),
      );

      try {
        final result = await _requestHandler.acceptExistingRequest(
          currentState.selectedUserId,
        );

        if (result['success']) {
          emit(AddFriendDialogSuccess(message: result['message']));
        } else {
          emit(
            AddFriendDialogError(
              error: result['message'],
              previousState: currentState,
            ),
          );
        }
      } catch (e) {
        emit(
          AddFriendDialogError(
            error: 'Error accepting friend request: $e',
            previousState: currentState,
          ),
        );
      }
    }
  }

  /// Reset to initial state
  void reset() {
    emit(AddFriendDialogInitial());
  }

  /// Clear search results
  void clearSearch() {
    emit(AddFriendDialogSearchResults(searchResults: [], selectedUserId: null));
  }

  /// Get current search results
  List<Map<String, dynamic>> getCurrentSearchResults() {
    final currentState = state;
    if (currentState is AddFriendDialogSearchResults) {
      return currentState.searchResults;
    } else if (currentState is AddFriendDialogCheckingStatus) {
      return currentState.searchResults;
    } else if (currentState is AddFriendDialogUserSelected) {
      return currentState.searchResults;
    } else if (currentState is AddFriendDialogSendingRequest) {
      return currentState.searchResults;
    } else if (currentState is AddFriendDialogAcceptingRequest) {
      return currentState.searchResults;
    }
    return [];
  }

  /// Get current selected user ID
  String? getCurrentSelectedUserId() {
    final currentState = state;
    if (currentState is AddFriendDialogSearchResults) {
      return currentState.selectedUserId;
    } else if (currentState is AddFriendDialogUserSelected) {
      return currentState.selectedUserId;
    } else if (currentState is AddFriendDialogSendingRequest) {
      return currentState.selectedUserId;
    } else if (currentState is AddFriendDialogAcceptingRequest) {
      return currentState.selectedUserId;
    }
    return null;
  }

  /// Check if currently searching
  bool get isSearching => state is AddFriendDialogSearching;

  /// Check if currently checking status
  bool get isCheckingStatus => state is AddFriendDialogCheckingStatus;

  /// Check if currently sending request
  bool get isSendingRequest => state is AddFriendDialogSendingRequest;

  /// Check if currently accepting request
  bool get isAcceptingRequest => state is AddFriendDialogAcceptingRequest;

  /// Check if user is selected
  bool get isUserSelected => state is AddFriendDialogUserSelected;

  /// Check if operation was successful
  bool get isSuccess => state is AddFriendDialogSuccess;

  /// Check if there's an error
  bool get hasError => state is AddFriendDialogError;
}
