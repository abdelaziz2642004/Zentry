import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';

class FriendRequestsCubit extends Cubit<FriendsState> {
  final FriendsService _friendsService = FriendsService();
  List<dynamic> _requests = [];

  FriendRequestsCubit() : super(FriendsInitialState());

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

  /// Send friend request by user ID
  Future<void> sendFriendRequestById({
    required String receiverId,
    required String message,
  }) async {
    emit(FriendsLoadingState());

    try {
      await _friendsService.sendFriendRequestById(
        receiverId: receiverId,
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
    // Only emit loading if we don't have data yet
    if (_requests.isEmpty) {
      emit(FriendsLoadingState());
    }

    _friendsService.getPendingFriendRequests().listen(
      (requests) {
        _requests = requests;
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
    _requests = [];
    emit(FriendsInitialState());
  }
}
