import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';

class FriendsListCubit extends Cubit<FriendsState> {
  final FriendsService _friendsService = FriendsService();
  List<dynamic> _friends = [];

  FriendsListCubit() : super(FriendsInitialState());

  /// Load friends list
  void loadFriendsList() {
    print('Loading friends list...');
    // Only emit loading if we don't have data yet
    if (_friends.isEmpty) {
      emit(FriendsLoadingState());
    }

    _friendsService.getFriendsList().listen(
      (friends) {
        _friends = friends;
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

  /// Clear error state
  void clearError() {
    emit(FriendsInitialState());
  }

  /// Reset cubit state and clear cached data
  void reset() {
    _friends = [];
    emit(FriendsInitialState());
  }
}
