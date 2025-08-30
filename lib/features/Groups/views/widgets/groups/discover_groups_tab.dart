import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/discovery_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/group_card_with_membership.dart';

class DiscoverGroupsTab extends StatelessWidget {
  final Function(dynamic) onJoinGroup;
  final Function(dynamic) onJoinPrivateGroup;
  final Function(dynamic) onNavigateToChat;

  const DiscoverGroupsTab({
    super.key,
    required this.onJoinGroup,
    required this.onJoinPrivateGroup,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryGroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is PublicGroupsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PublicGroupsLoadedState) {
          final groups = state.groups;
          if (groups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DiscoveryGroupsCubit>().loadPublicGroups();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GroupCardWithMembership(
                  group: group,
                  onJoin: () {
                    if (group.isPrivate) {
                      onJoinPrivateGroup(group);
                    } else {
                      onJoinGroup(group);
                    }
                  },
                  onChat:
                      (isMember) => isMember ? onNavigateToChat(group) : null,
                );
              },
            ),
          );
        }

        if (state is GroupsErrorState) {
          return _buildErrorState(context, state.error);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No groups found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or create a new group!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DiscoveryGroupsCubit>().loadPublicGroups();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
