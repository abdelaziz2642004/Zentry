import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/blocked_users_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/blocked_user_card.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/empty_blocked_users_widget.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late BlockedUsersCubit _blockedUsersCubit;

  @override
  void initState() {
    super.initState();
    _blockedUsersCubit = BlocProvider.of<BlockedUsersCubit>(context);
    _blockedUsersCubit.loadBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: BlocListener<BlockedUsersCubit, FriendsState>(
        listener: (context, state) {
          if (state is FriendsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is UserUnblockedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User unblocked successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<BlockedUsersCubit, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BlockedUsersLoadedState) {
              if (state.blockedUsers.isEmpty) {
                return const EmptyBlockedUsersWidget();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _blockedUsersCubit.loadBlockedUsers();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.blockedUsers.length,
                  itemBuilder: (context, index) {
                    final blockedUser = state.blockedUsers[index];
                    return BlockedUserCard(
                      blockedUser: blockedUser,
                      onUnblock: () {
                        _blockedUsersCubit.unblockUser(blockedUser['id']);
                      },
                    );
                  },
                ),
              );
            }

            return const Center(child: Text('No blocked users'));
          },
        ),
      ),
    );
  }
}
