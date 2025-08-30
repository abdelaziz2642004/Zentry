import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FriendsService _friendsService = FriendsService();
  String? _selectedUserId;
  String? _selectedUsername;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _friendsService.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendRequestsCubit, FriendsState>(
      listener: (context, state) {
        if (state is FriendRequestSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request sent!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is FriendsErrorState) {
          String errorMessage = 'Error sending friend request';

          // Handle specific error cases
          if (state.error.contains('Friend request already sent')) {
            errorMessage =
                'Request already sent! Please wait for them to accept or decline so you can send again.';
          } else if (state.error.contains('Already friends')) {
            errorMessage = 'You are already friends with this person!';
          } else if (state.error.contains(
            'Cannot send friend request to yourself',
          )) {
            errorMessage = 'You cannot send a friend request to yourself!';
          } else if (state.error.contains('user is blocked')) {
            errorMessage =
                'Cannot send friend request - user is blocked or has blocked you.';
          } else if (state.error.contains('User not found')) {
            errorMessage = 'User not found.';
          } else {
            errorMessage = 'Error sending friend request: ${state.error}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Add Friend'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by username',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _isSearching
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _searchUsers(value);
                },
              ),
              const SizedBox(height: 16),
              Flexible(
                child: BlocBuilder<FriendRequestsCubit, FriendsState>(
                  builder: (context, state) {
                    if (_isSearching) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (_searchResults.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUserId == user['id'];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  user['imageUrl'] != null &&
                                          user['imageUrl'].isNotEmpty
                                      ? NetworkImage(user['imageUrl'])
                                      : null,
                              child:
                                  user['imageUrl'] == null ||
                                          user['imageUrl'].isEmpty
                                      ? Text(
                                        (user['fullName'] ?? 'U')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                      : null,
                            ),
                            title: Text(user['fullName'] ?? ''),
                            subtitle: Text('@${user['username']}'),
                            trailing:
                                isSelected
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: mainColor,
                                    )
                                    : null,
                            onTap: () {
                              setState(() {
                                _selectedUserId = user['id'];
                                _selectedUsername = user['username'];
                              });
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              if (_selectedUserId != null) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<FriendRequestsCubit, FriendsState>(
                    builder: (context, state) {
                      final isLoading = state is FriendsLoadingState;

                      return ElevatedButton(
                        onPressed:
                            _selectedUserId != null && !isLoading
                                ? () {
                                  context
                                      .read<FriendRequestsCubit>()
                                      .sendFriendRequestById(
                                        receiverId: _selectedUserId!,
                                        message: _messageController.text,
                                      );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Send Request'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
