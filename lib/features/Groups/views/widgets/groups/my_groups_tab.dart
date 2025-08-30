import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/my_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/group_card_with_membership.dart';

class MyGroupsTab extends StatelessWidget {
  final Function(dynamic) onLeaveGroup;
  final Function(dynamic) onNavigateToChat;

  const MyGroupsTab({
    super.key,
    required this.onLeaveGroup,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyGroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is UserGroupsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserGroupsLoadedState) {
          if (state.groups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MyGroupsCubit>().loadUserJoinedGroups();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return GroupCardWithMembership(
                  group: group,
                  onLeave: () => onLeaveGroup(group),
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
          Icon(Icons.group_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No groups joined yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Join some groups to start studying together!',
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
              context.read<MyGroupsCubit>().loadUserJoinedGroups();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
