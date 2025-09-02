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

        // Debug prints to understand what's happening
        print('🔍 Recentlyjoined widget - State: ${state.runtimeType}');
        print('🔍 Recentlyjoined widget - Room: ${room?.name ?? "null"}');
        print(
          '🔍 Recentlyjoined widget - Room finished: ${room?.isFinished ?? "null"}',
        );

        if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          room = (state as dynamic).room;
          print(
            '🔍 Recentlyjoined widget - Updated room from state: ${room?.name ?? "null"}',
          );
        }

        if (room == null) {
          print('🔍 Recentlyjoined widget - No room, returning empty SizedBox');
          return const SizedBox(); // empty placeholder
        }

        // Check if the room has finished all sessions
        if (room.isFinished) {
          print(
            '🔍 Recentlyjoined widget - Room is finished, returning empty SizedBox',
          );
          return const SizedBox(); // Hide finished rooms
        }

        print('🔍 Recentlyjoined widget - Showing room: ${room.name}');
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildCompactRejoinCard(context, room!, roomCubit),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactRejoinCard(
    BuildContext context,
    PomodoroRoom room,
    RoomCubit roomCubit,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF05161A), Color(0xFF072E33)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2CACAD).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),

                    // Room info - compact layout
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Room name
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD9F5F0),
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // User count and capacity - compact
                          _buildCompactUserCount(room),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Rejoin text and loading icon
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Rejoin",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF75E2E0).withOpacity(0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2CACAD).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF2CACAD).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Color(0xFF75E2E0),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactUserCount(PomodoroRoom room) {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance
              .ref(FirebaseConstants.getRoomUsersPath(room.roomCode))
              .onValue,
      builder: (context, snapshot) {
        int userCount = 0;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;
          userCount = data.length;
        }

        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9E9C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F9E9C).withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$userCount/${room?.capacity.toString() ?? "-"} active",
              style: TextStyle(
                color: const Color(0xFF75E2E0).withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
