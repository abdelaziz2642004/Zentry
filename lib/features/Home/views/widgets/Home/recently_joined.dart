import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';

import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';

class Recentlyjoined extends StatelessWidget {
  const Recentlyjoined({super.key});

  @override
  Widget build(BuildContext context) {
    final roomCubit = BlocProvider.of<RoomCubit>(context);
    return BlocBuilder<RoomCubit, RoomStates>(
      buildWhen: (prev, current) {
        return current is RecentlyUpdated ||
            current is RoomJoinSuccess ||
            current is RoomUsersUpdated;
      },
      builder: (context, state) {
        PomodoroRoom? room = BlocProvider.of<RoomCubit>(context).recently;
        if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          room = (state as dynamic).room;
        }
        if (room == null) {
          return const SizedBox(); // empty placeholder
        }

        // Check if the room has finished all sessions
        if (room.isFinished) {
          return const SizedBox(); // Hide finished rooms
        }

        return Column(
          children: [
            const Text(
              "Recently Joined",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Capture context and room data before async operations
                final currentContext = context;
                final currentRoom = room;

                // Check if already joining a room
                final currentState = roomCubit.state;
                if (currentState.runtimeType.toString() ==
                    'RoomJoinLoadingState') {
                  if (currentContext.mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      failedSnackBar(
                        msg: 'Already joining a room. Please wait.',
                      ),
                    );
                  }
                  return;
                }

                // Check if room still exists before navigating
                if (currentRoom == null) {
                  if (currentContext.mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      failedSnackBar(msg: 'Room no longer exists'),
                    );
                  }
                  return;
                }

                final roomRef = FirebaseDatabase.instance.ref(
                  FirebaseConstants.getRoomPath(currentRoom.roomCode),
                );
                final roomSnapshot = await roomRef.get();

                // Check if widget is still mounted before using context
                if (!currentContext.mounted) return;

                if (!roomSnapshot.exists) {
                  ScaffoldMessenger.of(
                    currentContext,
                  ).showSnackBar(failedSnackBar(msg: 'Room no longer exists'));
                  return;
                }

                Navigator.push(
                  currentContext,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider.value(
                          value: roomCubit,
                          child: RoomScreen(roomCode: currentRoom.roomCode),
                        ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          StreamBuilder<DatabaseEvent>(
                            stream:
                                FirebaseDatabase.instance
                                    .ref(
                                      FirebaseConstants.getRoomUsersPath(
                                        room.roomCode,
                                      ),
                                    )
                                    .onValue,
                            builder: (context, snapshot) {
                              int userCount = 0;
                              if (snapshot.hasData &&
                                  snapshot.data!.snapshot.value != null) {
                                final data =
                                    snapshot.data!.snapshot.value as Map;
                                userCount = data.length;
                              }
                              return Text(
                                "$userCount/${room?.capacity.toString() ?? "-"} active",
                                style: const TextStyle(color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
