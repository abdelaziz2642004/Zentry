import 'package:zentry_pomodoro_app/features/Friends/data/models/friend.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend_request.dart';

abstract class FriendsState {}

class FriendsInitialState extends FriendsState {}

class FriendsLoadingState extends FriendsState {}

class FriendsErrorState extends FriendsState {
  final String error;
  FriendsErrorState(this.error);
}

// Friend Requests States
class PendingFriendRequestsLoadedState extends FriendsState {
  final List<FriendRequest> requests;
  PendingFriendRequestsLoadedState(this.requests);
}

class FriendRequestSentState extends FriendsState {}

class FriendRequestAcceptedState extends FriendsState {}

class FriendRequestRejectedState extends FriendsState {}

// Friends List States
class FriendsListLoadedState extends FriendsState {
  final List<Friend> friends;
  FriendsListLoadedState(this.friends);
}

class FriendRemovedState extends FriendsState {}

// Blocked Users States
class BlockedUsersLoadedState extends FriendsState {
  final List<Map<String, dynamic>> blockedUsers;
  BlockedUsersLoadedState(this.blockedUsers);
}

class UserBlockedState extends FriendsState {}

class UserUnblockedState extends FriendsState {}

// User Search States
class UsersSearchResultState extends FriendsState {
  final List<Map<String, dynamic>> users;
  UsersSearchResultState(this.users);
}

class UsersSearchClearedState extends FriendsState {}
