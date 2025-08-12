import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:async/async.dart';

class Joineduserspart extends StatelessWidget {
  const Joineduserspart({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
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
          final userIds = roomDetails.joinedUsers;

          if (userIds.isEmpty) {
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

          final userIdChunks = chunked(userIds, 10);
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
                return Text('Error: \\${snapshot.error}');
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
                    userIds.map<Widget>((userId) {
                      final userDoc = userMap[userId];
                      if (userDoc == null || !userDoc.exists) {
                        return const ListTile(title: Text("User not found"));
                      }
                      final userData = userDoc.data() as Map<String, dynamic>;

                      final userName =
                          userData[FirebaseConstants.fullNameField] ??
                          'Unknown User';
                      // print(userName);
                      final userImage =
                          userData[FirebaseConstants.imageUrlField] ?? '';
                      return ListTile(
                        leading:
                            userImage.isNotEmpty
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(userImage),
                                )
                                : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(userName),
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
