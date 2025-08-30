import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_list_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_card.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/empty_friends_widget.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsListCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FriendsListLoadedState) {
          if (state.friends.isEmpty) {
            return const EmptyFriendsWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<FriendsListCubit>(context).loadFriendsList();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.friends.length,
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return FriendCard(
                  friend: friend,
                  onRemove: () {
                    // Handle friend removal
                    BlocProvider.of<FriendsListCubit>(
                      context,
                    ).removeFriend(friend.id);
                  },
                );
              },
            ),
          );
        } else if (state is FriendsErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading friends',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<FriendsListCubit>(
                      context,
                    ).loadFriendsList();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text(''));
      },
    );
  }
}
