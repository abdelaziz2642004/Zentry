import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/services/groups_service.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupsService _groupsService = GroupsService();
  List<String> _userJoinedGroupIds = [];
  List<dynamic> _publicGroups = [];
  List<dynamic> _userGroups = [];

  GroupsCubit() : super(GroupsInitialState());

  /// Create a new study group
  Future<void> createGroup({
    required String name,
    required String description,
    required bool isPublic,
    required int maxMembers,
    required List<String> tags,
    required String category,
    String? imageUrl,
    String? password, // Add password for private groups
  }) async {
    emit(GroupCreatingState());

    try {
      final groupId = await _groupsService.createGroup(
        name: name,
        description: description,
        isPublic: isPublic,
        maxMembers: maxMembers,
        tags: tags,
        category: category,
        imageUrl: imageUrl,
        password: password,
      );
      emit(GroupCreatedState(groupId));
      // Reload groups after creation
      loadPublicGroups();
      loadUserJoinedGroups();
    } catch (e) {
      emit(GroupCreationFailedState(e.toString()));
    }
  }

  /// Load public groups
  void loadPublicGroups() {
    // Only emit loading if we don't have data yet
    if (_publicGroups.isEmpty) {
      emit(PublicGroupsLoadingState());
    }

    _groupsService.getPublicGroups().listen(
      (groups) {
        _publicGroups = groups;
        emit(PublicGroupsLoadedState(groups));
      },
      onError: (error) {
        emit(GroupsErrorState(error.toString()));
      },
    );
  }

  /// Load groups by category
  void loadGroupsByCategory(String category) {
    emit(PublicGroupsLoadingState());

    _groupsService
        .getGroupsByCategory(category)
        .listen(
          (groups) {
            _publicGroups = groups;
            emit(PublicGroupsLoadedState(groups));
          },
          onError: (error) {
            emit(GroupsErrorState(error.toString()));
          },
        );
  }

  /// Load user's joined groups
  void loadUserJoinedGroups() {
    // Only emit loading if we don't have data yet
    if (_userGroups.isEmpty) {
      emit(UserGroupsLoadingState());
    }

    _groupsService.getUserJoinedGroups().listen(
      (groups) {
        _userGroups = groups;
        // Update the list of joined group IDs
        _userJoinedGroupIds = groups.map((group) => group.id).toList();
        emit(UserGroupsLoadedState(groups));
      },
      onError: (error) {
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
      // Reload user's groups
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
      // Reload user's groups
      loadUserJoinedGroups();
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Search groups
  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      emit(GroupsSearchClearedState());
      return;
    }

    emit(PublicGroupsLoadingState());

    try {
      final groups = await _groupsService.searchGroups(query);
      emit(GroupsSearchResultState(groups));
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Get group details
  Future<void> getGroupDetails(String groupId) async {
    emit(GroupsLoadingState());

    try {
      final group = await _groupsService.getGroupDetails(groupId);
      if (group != null) {
        emit(GroupDetailsLoadedState(group));
      } else {
        emit(GroupsErrorState('Group not found'));
      }
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Check if user is member of a group
  bool isUserMember(String groupId) {
    return _userJoinedGroupIds.contains(groupId);
  }

  /// Check if user is member of a group (async version)
  Future<bool> isUserMemberAsync(String groupId) async {
    try {
      return await _groupsService.isUserMember(groupId);
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
      return false;
    }
  }

  /// Check if user is admin of a group
  Future<bool> isUserAdmin(String groupId) async {
    try {
      return await _groupsService.isUserAdmin(groupId);
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
      return false;
    }
  }

  /// Add member as admin
  Future<void> addAdmin(String groupId, String memberId) async {
    emit(GroupsLoadingState());

    try {
      await _groupsService.addAdmin(groupId, memberId);
      emit(AdminAddedState());
      // Reload group details
      getGroupDetails(groupId);
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Remove admin
  Future<void> removeAdmin(String groupId, String memberId) async {
    emit(GroupsLoadingState());

    try {
      await _groupsService.removeAdmin(groupId, memberId);
      emit(AdminRemovedState());
      // Reload group details
      getGroupDetails(groupId);
    } catch (e) {
      emit(GroupsErrorState(e.toString()));
    }
  }

  /// Update group activity
  Future<void> updateGroupActivity(String groupId) async {
    try {
      await _groupsService.updateGroupActivity(groupId);
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
    _publicGroups = [];
    _userGroups = [];
    _userJoinedGroupIds = [];
    emit(GroupsInitialState());
  }
}
