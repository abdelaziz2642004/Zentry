import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_list_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friends_list/friend_card.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/empty_states/empty_friends_widget.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsListCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2CACAD)),
            ),
          );
        } else if (state is FriendsListLoadedState) {
          if (state.friends.isEmpty) {
            return const EmptyFriendsWidget();
          }

          return RefreshIndicator(
            color: const Color(0xFF2CACAD),
            backgroundColor: const Color(0xFF05161A),
            onRefresh: () async {
              BlocProvider.of<FriendsListCubit>(context).loadFriendsList();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemCount: state.friends.length,
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: FriendCard(
                          friend: friend,
                          onRemove: () {
                            BlocProvider.of<FriendsListCubit>(
                              context,
                            ).removeFriend(friend.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is FriendsErrorState) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF05161A).withOpacity(0.8),
                    const Color(0xFF072E33).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2CACAD).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: const Color(0xFF2CACAD).withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading friends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD9F5F0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFD9F5F0).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<FriendsListCubit>(
                        context,
                      ).loadFriendsList();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CACAD),
                      foregroundColor: const Color(0xFF05161A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Center(
          child: Text('', style: TextStyle(color: const Color(0xFFD9F5F0))),
        );
      },
    );
  }
}
