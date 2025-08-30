import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_requests/friend_request_card.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/empty_states/empty_requests_widget.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendRequestsCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PendingFriendRequestsLoadedState) {
          if (state.requests.isEmpty) {
            return const EmptyRequestsWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<FriendRequestsCubit>(
                context,
              ).loadPendingFriendRequests();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return FriendRequestCard(
                  request: request,
                  onAccept: () {
                    BlocProvider.of<FriendRequestsCubit>(
                      context,
                    ).acceptFriendRequest(request.id);
                  },
                  onReject: () {
                    BlocProvider.of<FriendRequestsCubit>(
                      context,
                    ).rejectFriendRequest(request.id);
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
                  'Error loading requests',
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
                    BlocProvider.of<FriendRequestsCubit>(
                      context,
                    ).loadPendingFriendRequests();
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
