import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/services/groups_service.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';

class DiscoveryGroupsCubit extends Cubit<GroupsState> {
  final GroupsService _groupsService = GroupsService();
  List<dynamic> _publicGroups = [];

  DiscoveryGroupsCubit() : super(GroupsInitialState());

  /// Load public groups
  void loadPublicGroups() {
    print('Loading public groups...');
    // Only emit loading if we don't have data yet
    if (_publicGroups.isEmpty) {
      emit(PublicGroupsLoadingState());
    }

    _groupsService.getPublicGroups().listen(
      (groups) {
        _publicGroups = groups;
        print('Public groups loaded: ${groups.length}');
        emit(PublicGroupsLoadedState(groups));
      },
      onError: (error) {
        print('Error loading public groups: $error');
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
            print('Groups by category loaded: ${groups.length}');
            emit(PublicGroupsLoadedState(groups));
          },
          onError: (error) {
            print('Error loading groups by category: $error');
            emit(GroupsErrorState(error.toString()));
          },
        );
  }

  /// Search groups
  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      loadPublicGroups();
      return;
    }

    emit(PublicGroupsLoadingState());

    try {
      final groups = await _groupsService.searchGroups(query);
      print('Search results: ${groups.length}');
      emit(GroupsSearchResultState(groups));
    } catch (error) {
      print('Error searching groups: $error');
      emit(GroupsErrorState(error.toString()));
    }
  }

  /// Clear error state
  void clearError() {
    emit(GroupsInitialState());
  }

  /// Reset cubit state and clear cached data
  void reset() {
    _publicGroups = [];
    emit(GroupsInitialState());
  }
}
