import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final FriendsService _friendsService = FriendsService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String? _selectedUserId;
  String? _selectedUsername;
  bool _isSearching = false;
  bool _isSearchingByCode = false;
  bool _isCheckingRequest = false;
  bool _hasExistingRequest = false;
  bool _isAlreadyFriends = false;

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
        _isSearchingByCode = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchingByCode = false;
    });

    try {
      // Only search by friend code (6 characters, alphanumeric)
      final isFriendCode =
          query.trim().length == 6 &&
          RegExp(r'^[A-Z0-9]{6}$').hasMatch(query.trim().toUpperCase());

      if (isFriendCode) {
        // Search by friend code
        final userData = await _friendsService.searchUserByFriendCode(
          query.trim(),
        );
        setState(() {
          _searchResults = userData != null ? [userData] : [];
          _isSearching = false;
          _isSearchingByCode = true;
        });
      } else {
        // Show error for invalid friend code format
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _isSearchingByCode = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid 6-character friend code'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _isSearchingByCode = false;
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

  Future<void> _checkExistingRequest(String userId) async {
    setState(() {
      _isCheckingRequest = true;
    });

    try {
      // Check if there's any pending request between the users
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      print('Checking existing request between $currentUserId and $userId');

      // Check if already friends
      final areFriends = await _friendsService.checkIfFriends(
        currentUserId,
        userId,
      );

      // Check if there's any pending request
      final hasRequest = await _friendsService.checkIfAnyFriendRequestPending(
        currentUserId,
        userId,
      );

      print('Are friends: $areFriends, Has existing request: $hasRequest');

      if (mounted) {
        setState(() {
          _isAlreadyFriends = areFriends;
          _hasExistingRequest = hasRequest;
          _isCheckingRequest = false;
        });
      }
    } catch (e) {
      print('Error checking existing request: $e');
      if (mounted) {
        setState(() {
          _isCheckingRequest = false;
        });
      }
    }
  }

  Future<void> _acceptExistingRequest() async {
    if (_selectedUserId == null) return;

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Find the existing request ID
      final requestId = await _friendsService.getFriendRequestId(
        _selectedUserId!,
        currentUserId,
      );

      if (requestId != null) {
        // Accept the existing request
        await _friendsService.acceptFriendRequest(requestId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request accepted!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting friend request: $e'),
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
                  labelText: 'Search by friend code',
                  hintText: 'Enter 6-character friend code',
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
                            leading: StreamBuilder<DocumentSnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection(
                                        FirebaseConstants.usersCollection,
                                      )
                                      .doc(user['id'])
                                      .snapshots(),
                              builder: (context, snapshot) {
                                String? imageUrl;
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>?;
                                  if (data != null) {
                                    imageUrl =
                                        data[FirebaseConstants.imageUrlField];
                                    if (imageUrl != null && imageUrl.isEmpty)
                                      imageUrl = null;
                                  }
                                }

                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                    onBackgroundImageError: (
                                      exception,
                                      stackTrace,
                                    ) {
                                      // Handle image loading error
                                    },
                                  );
                                } else {
                                  return CircleAvatar(
                                    backgroundColor: Colors.grey[400],
                                    child: Text(
                                      (user['fullName'] ?? 'U')[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            title: StreamBuilder<DocumentSnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection(
                                        FirebaseConstants.usersCollection,
                                      )
                                      .doc(user['id'])
                                      .snapshots(),
                              builder: (context, snapshot) {
                                String displayName = user['fullName'] ?? '';
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>?;
                                  if (data != null) {
                                    displayName =
                                        data[FirebaseConstants.fullNameField] ??
                                        displayName;
                                  }
                                }
                                return Text(displayName);
                              },
                            ),
                            subtitle: Text(
                              'Friend Code: ${user['friendCode'] ?? ''}',
                            ),
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
                                _hasExistingRequest = false; // Reset state
                                _isAlreadyFriends = false; // Reset state
                              });
                              _checkExistingRequest(user['id']);
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
                      final isDisabled =
                          _selectedUserId == null ||
                          isLoading ||
                          _isCheckingRequest;

                      // Determine button text and action
                      String buttonText = 'Send Request';
                      VoidCallback? buttonAction;

                      if (_isCheckingRequest) {
                        buttonText = 'Checking...';
                      } else if (_isAlreadyFriends) {
                        buttonText = 'Already Friends';
                        buttonAction = null; // Disable button
                      } else if (_hasExistingRequest) {
                        buttonText = 'Accept Request';
                        buttonAction = () => _acceptExistingRequest();
                      } else if (!isDisabled) {
                        buttonAction = () {
                          context
                              .read<FriendRequestsCubit>()
                              .sendFriendRequestById(
                                receiverId: _selectedUserId!,
                                message: _messageController.text,
                              );
                        };
                      }

                      return ElevatedButton(
                        onPressed:
                            isDisabled || _isAlreadyFriends
                                ? null
                                : buttonAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isAlreadyFriends
                                  ? Colors.grey
                                  : _hasExistingRequest
                                  ? Colors.green
                                  : mainColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isCheckingRequest
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
                                : isLoading
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
                                : Text(buttonText),
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
