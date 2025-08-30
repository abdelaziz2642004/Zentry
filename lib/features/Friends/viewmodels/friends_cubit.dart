import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsService _friendsService = FriendsService();

  FriendsCubit() : super(FriendsInitialState());

  /// Send friend request
  Future<void> sendFriendRequest({
    required String receiverUsername,
    required String message,
  }) async {
    emit(FriendsLoadingState());

    try {
      await _friendsService.sendFriendRequest(
        receiverUsername: receiverUsername,
        message: message,
      );
      emit(FriendRequestSentState());
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Get pending friend requests
  void loadPendingFriendRequests() {
    print('Loading pending friend requests...');
    emit(FriendsLoadingState());

    _friendsService.getPendingFriendRequests().listen(
      (requests) {
        print('Friend requests loaded: ${requests.length}');
        emit(PendingFriendRequestsLoadedState(requests));
      },
      onError: (error) {
        print('Error loading friend requests: $error');
        emit(FriendsErrorState(error.toString()));
      },
    );
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    emit(FriendsLoadingState());

    try {
      await _friendsService.acceptFriendRequest(requestId);
      emit(FriendRequestAcceptedState());
      // Reload pending requests
      loadPendingFriendRequests();
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    emit(FriendsLoadingState());

    try {
      await _friendsService.rejectFriendRequest(requestId);
      emit(FriendRequestRejectedState());
      // Reload pending requests
      loadPendingFriendRequests();
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Load friends list
  void loadFriendsList() {
    print('Loading friends list...');
    emit(FriendsLoadingState());

    _friendsService.getFriendsList().listen(
      (friends) {
        print('Friends loaded: ${friends.length}');
        emit(FriendsListLoadedState(friends));
      },
      onError: (error) {
        print('Error loading friends: $error');
        emit(FriendsErrorState(error.toString()));
      },
    );
  }

  /// Remove friend
  Future<void> removeFriend(String friendId) async {
    emit(FriendsLoadingState());

    try {
      await _friendsService.removeFriend(friendId);
      emit(FriendRemovedState());
      // Reload friends list
      loadFriendsList();
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      emit(UsersSearchClearedState());
      return;
    }

    emit(FriendsLoadingState());

    try {
      final users = await _friendsService.searchUsers(query);
      emit(UsersSearchResultState(users));
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Clear error state
  void clearError() {
    emit(FriendsInitialState());
  }

  /// Reset cubit state and clear cached data
  void reset() {
    emit(FriendsInitialState());
  }
}
