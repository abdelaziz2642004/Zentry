import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:async/async.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class Joineduserspart extends StatefulWidget {
  const Joineduserspart({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<Joineduserspart> createState() => _JoineduserspartState();
}

class _JoineduserspartState extends State<Joineduserspart> {
  final Map<String, Timer> _timers = {};
  final Map<String, int> _remainingSeconds = {};

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _startTimer(String userId) {
    _timers[userId]?.cancel();

    if (mounted) {
      setState(() {
        _remainingSeconds[userId] = 120;
      });
    }

    _timers[userId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds.containsKey(userId)) {
        if (_remainingSeconds[userId]! > 0) {
          if (mounted) {
            setState(() {
              _remainingSeconds[userId] = _remainingSeconds[userId]! - 1;
            });
          }
        } else {
          timer.cancel();
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.uid == userId) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Disconnected"),
                    content: const Text(
                      "You have been removed from the room due to inactivity.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<RoomCubit>().leaveRoomLocally();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
            );
          }
          if (mounted) {
            setState(() {
              _timers.remove(userId);
              _remainingSeconds.remove(userId);
            });
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomStates>(
      listener: (context, state) {
        if (state is RoomUsersUpdated) {
          for (var userId in state.disconnectedUsers) {
            _startTimer(userId);
          }

          final onlineUserIds = state.room.joinedUsers;
          final reconnectedUsers =
              _timers.keys
                  .where((userId) => onlineUserIds.contains(userId))
                  .toList();

          if (reconnectedUsers.isNotEmpty) {
            if (mounted) {
              setState(() {
                for (var userId in reconnectedUsers) {
                  _timers[userId]?.cancel();
                  _timers.remove(userId);
                  _remainingSeconds.remove(userId);
                }
              });
            }
          }
        } else if (state is RoomJoinSuccess) {
          if (mounted) {
            setState(() {
              for (var timer in _timers.values) {
                timer.cancel();
              }
              _timers.clear();
              _remainingSeconds.clear();
            });
          }
        }
      },
      buildWhen: (previous, current) {
        return current is RoomJoinSuccess ||
            current is RoomJoinFailure ||
            current is RoomJoinLoadingState ||
            current is RoomUsersUpdated;
      },
      builder: (context, state) {
        if (state is RoomJoinLoadingState) {
          return const CircularProgressIndicator();
        } else if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          final roomDetails = (state as dynamic).room;
          final onlineUserIds = roomDetails.joinedUsers as List<String>;

          final allUserIds =
              (onlineUserIds.toSet()..addAll(_remainingSeconds.keys)).toList();

          if (allUserIds.isEmpty) {
            return const Text("No users in this room.");
          }

          // Helper to split list into chunks of 10
          List<List<String>> chunked(List<String> list, int size) {
            final List<List<String>> chunks = [];
            for (var i = 0; i < list.length; i += size) {
              chunks.add(
                list.sublist(
                  i,
                  i + size > list.length ? list.length : i + size,
                ),
              );
            }
            return chunks;
          }

          final userIdChunks = chunked(allUserIds, 10);
          final streams =
              userIdChunks
                  .map(
                    (chunk) =>
                        FirebaseFirestore.instance
                            .collection(FirebaseConstants.usersCollection)
                            .where(FieldPath.documentId, whereIn: chunk)
                            .snapshots(),
                  )
                  .toList();

          return StreamBuilder<List<QuerySnapshot>>(
            stream: StreamZip(streams),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              // Merge all docs from all snapshots
              final allDocs = snapshot.data!.expand((qs) => qs.docs).toList();
              if (allDocs.isEmpty) {
                return const Text("No users found.");
              }
              // Map userIds to user documents for correct order
              final userMap = {for (var doc in allDocs) doc.id: doc};
              return Column(
                children:
                    allUserIds.map<Widget>((userId) {
                      final userDoc = userMap[userId];
                      final remaining = _remainingSeconds[userId] ?? 0;
                      return UserTile(
                        userDoc: userDoc,
                        remainingSeconds: remaining,
                        userId: userId,
                      );
                    }).toList(),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class UserTile extends StatelessWidget {
  final DocumentSnapshot? userDoc;
  final int remainingSeconds;
  final String userId;

  const UserTile({
    super.key,
    required this.userDoc,
    required this.remainingSeconds,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (userDoc == null || !userDoc!.exists) {
      return const ListTile(title: Text("User not found"));
    }
    final userData = userDoc!.data() as Map<String, dynamic>;

    final userName =
        userData[FirebaseConstants.fullNameField] ?? 'Unknown User';
    final userImage = userData[FirebaseConstants.imageUrlField] ?? '';

    bool isDisconnected = remainingSeconds > 0;

    return ListTile(
      leading:
          userImage.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(userImage))
              : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(userName),
      trailing:
          isDisconnected
              ? Text(
                '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.red),
              )
              : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
      onTap: () => _showUserProfilePopup(context, userId, userName, userImage),
    );
  }

  void _showUserProfilePopup(
    BuildContext context,
    String userId,
    String userName,
    String userImage,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProfilePopupDialog(userId: userId),
    );
  }
}
