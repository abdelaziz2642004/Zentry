import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';

class BlockedUsersCubit extends Cubit<FriendsState> {
  final BlockService _blockService = BlockService();
  final FriendsService _friendsService = FriendsService();
  List<Map<String, dynamic>> _blockedUsers = [];

  BlockedUsersCubit() : super(FriendsInitialState());

  /// Load blocked users list
  void loadBlockedUsers() {
    emit(FriendsLoadingState());

    _friendsService.getBlockedUsers().listen(
      (blockedUsers) {
        _blockedUsers = blockedUsers;
        emit(BlockedUsersLoadedState(blockedUsers));
      },
      onError: (error) {
        emit(FriendsErrorState(error.toString()));
      },
    );
  }

  /// Unblock a user
  Future<void> unblockUser(String userId) async {
    try {
      await _blockService.unblockUser(userId);
      emit(UserUnblockedState());
      // Reload blocked users list
      loadBlockedUsers();
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Block a user
  Future<void> blockUser(String userId) async {
    try {
      await _blockService.blockUser(userId);
      emit(UserBlockedState());
      // Reload blocked users list
      loadBlockedUsers();
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String userId) async {
    return await _blockService.isUserBlocked(userId);
  }

  /// Clear error state
  void clearError() {
    emit(FriendsInitialState());
  }

  /// Reset cubit state
  void reset() {
    _blockedUsers = [];
    emit(FriendsInitialState());
  }
}
