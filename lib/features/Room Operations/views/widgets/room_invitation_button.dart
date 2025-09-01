import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/chat_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class RoomInvitationButton extends StatefulWidget {
  final String roomCode;
  final String roomName;

  const RoomInvitationButton({
    super.key,
    required this.roomCode,
    required this.roomName,
  });

  @override
  State<RoomInvitationButton> createState() => _RoomInvitationButtonState();
}

class _RoomInvitationButtonState extends State<RoomInvitationButton> {
  final ChatService _chatService = ChatService();
  final FriendsService _friendsService = FriendsService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get friends list
      await _friendsService.getFriendsList().first.then((friends) {
        setState(() {
          _friends =
              friends
                  .map(
                    (friend) => {
                      'id': friend.id,
                      'name': friend.fullName,
                      'username': friend.username,
                    },
                  )
                  .toList();
        });
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person_add),
      onPressed: _showInviteDialog,
      tooltip: 'Invite Friends',
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Invite Friends'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _friends.isEmpty
                      ? const Center(child: Text('No friends to invite'))
                      : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return ListTile(
                            leading: StreamBuilder<String>(
                              stream: _userService.getUserImageUrlStream(
                                friend['id'],
                              ),
                              builder: (context, snapshot) {
                                String? imageUrl = snapshot.data;

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
                                      friend['name']?[0]?.toUpperCase() ?? '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            title: StreamBuilder<String>(
                              stream: _userService.getUserNameStream(
                                friend['id'],
                              ),
                              builder: (context, snapshot) {
                                final displayName =
                                    snapshot.data ?? friend['name'] ?? '';
                                return Text(displayName);
                              },
                            ),
                            subtitle: Text('@${friend['username']}'),
                            trailing: ElevatedButton(
                              onPressed: () => _inviteFriend(friend),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Invite'),
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _inviteFriend(Map<String, dynamic> friend) async {
    try {
      await _chatService.sendRoomInvitation(
        receiverId: friend['id'],
        receiverName: friend['name'],
        roomCode: widget.roomCode,
        roomName: widget.roomName,
        message: 'Join me in studying!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${friend['name']}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
