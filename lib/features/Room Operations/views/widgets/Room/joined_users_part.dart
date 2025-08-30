import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:async/async.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

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
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap:
                            () => _showUserProfilePopup(
                              context,
                              userId,
                              userName,
                              userImage,
                            ),
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

  Widget _buildWeeklyStudyTime(String userId) {
    // Get current week's dates (Saturday to Friday)
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday

    // Calculate Saturday of current week (weekday 6)
    final saturday = now.subtract(Duration(days: currentWeekday - 6));

    return FutureBuilder<Map<DateTime, Duration>>(
      future: _getWeeklyStudyData(userId, saturday),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Error loading study data',
            style: TextStyle(color: Colors.red),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final studyData = snapshot.data!;

        return Column(
          children: [
            // Days of the week
            Row(
              children:
                  ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((day) {
                    final isToday = _isToday(day, now);
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 4),

            // Study time bars
            Row(
              children: List.generate(7, (index) {
                final date = saturday.add(Duration(days: index));
                final studyTime = studyData[date] ?? Duration.zero;
                final isToday = _isToday(
                  ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'][index],
                  now,
                );
                final isFuture = date.isAfter(now);

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      children: [
                        // Study time bar
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isFuture
                                    ? Colors.grey[300]
                                    : studyTime.inMinutes > 0
                                    ? Colors.green[400]
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                            border:
                                isToday
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                          ),
                          child: Center(
                            child: Text(
                              _formatStudyTime(studyTime),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color:
                                    isFuture || studyTime.inMinutes == 0
                                        ? Colors.grey[600]
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Future<Map<DateTime, Duration>> _getWeeklyStudyData(
    String userId,
    DateTime saturday,
  ) async {
    final Map<DateTime, Duration> result = {};

    for (int i = 0; i < 7; i++) {
      final date = saturday.add(Duration(days: i));
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      try {
        final doc =
            await FirebaseFirestore.instance
                .collection(FirebaseConstants.dailyStatsCollection)
                .doc(userId)
                .collection('dates')
                .doc(dateString)
                .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          final studyTimeSeconds =
              data?[FirebaseConstants.totalStudyTimeField] ?? 0;
          result[date] = Duration(seconds: studyTimeSeconds);
        } else {
          result[date] = Duration.zero;
        }
      } catch (e) {
        result[date] = Duration.zero;
      }
    }

    return result;
  }

  bool _isToday(String day, DateTime now) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDay = weekdays[now.weekday - 1];
    return day == currentDay;
  }

  String _formatStudyTime(Duration duration) {
    if (duration.inMinutes == 0) return '0';
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    }
    return '${duration.inMinutes}m';
  }
}
