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
            color: const Color(0xFF2CACAD),
            backgroundColor: const Color(0xFF072E33),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85, // Reduced height for more compact cards
              ),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: Opacity(
                          opacity: value,
                          child: GroupCardWithMembership(
                            group: group,
                            onLeave: () => onLeaveGroup(group),
                            onChat:
                                (isMember) =>
                                    isMember ? onNavigateToChat(group) : null,
                          ),
                        ),
                      ),
                    );
                  },
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF05161A).withOpacity(0.8),
                      const Color(0xFF072E33).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF2CACAD).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated groups icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 2000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, pulseValue, child) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF2CACAD).withOpacity(0.2),
                                const Color(0xFF2CACAD).withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2CACAD,
                                ).withOpacity(0.2 + (0.1 * pulseValue)),
                                blurRadius: 20 + (10 * pulseValue),
                                spreadRadius: 2 + (3 * pulseValue),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.groups_outlined,
                            size: 64,
                            color: const Color(0xFF2CACAD).withOpacity(0.8),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Text(
                      '📚 No groups joined yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD9F5F0),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Join study groups and collaborate with fellow learners on your academic journey',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD9F5F0).withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
