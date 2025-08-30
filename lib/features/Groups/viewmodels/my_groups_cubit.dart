import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/services/groups_service.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';

class MyGroupsCubit extends Cubit<GroupsState> {
  final GroupsService _groupsService = GroupsService();
  List<dynamic> _userGroups = [];

  MyGroupsCubit() : super(GroupsInitialState());

  /// Load user's joined groups
  void loadUserJoinedGroups() {
    print('Loading user joined groups...');
    // Only emit loading if we don't have data yet
    if (_userGroups.isEmpty) {
      emit(UserGroupsLoadingState());
    }

    _groupsService.getUserJoinedGroups().listen(
      (groups) {
        _userGroups = groups;
        print('User groups loaded: ${groups.length}');
        emit(UserGroupsLoadedState(groups));
      },
      onError: (error) {
        print('Error loading user groups: $error');
        emit(GroupsErrorState(error.toString()));
      },
    );
  }

  /// Join a group
  Future<void> joinGroup(String groupId, {String? password}) async {
    emit(GroupJoiningState());

    try {
      await _groupsService.joinGroup(groupId, password: password);
      emit(GroupJoinedState());
      // Reload user groups after joining
      loadUserJoinedGroups();
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    emit(GroupLeavingState());

    try {
      await _groupsService.leaveGroup(groupId);
      emit(GroupLeftState());
      // Reload user groups after leaving
      loadUserJoinedGroups();
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Clear error state
  void clearError() {
    emit(GroupsInitialState());
  }

  /// Reset cubit state and clear cached data
  void reset() {
    _userGroups = [];
    emit(GroupsInitialState());
  }
}
