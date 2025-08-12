import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/SuccessSnackBar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/room_phase_timer.dart';

class RoomDetailsAndTimer extends StatelessWidget {
  const RoomDetailsAndTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      buildWhen: (previous, current) {
        // Return true only for the specific states you want to rebuild for
        return current is RoomJoinSuccess ||
            current is RoomUsersUpdated ||
            current is RoomJoinFailure ||
            current is RoomJoinLoadingState;
      },
      builder: (context, state) {
        if (state is RoomJoinLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RoomJoinFailure) {
          return Center(
            child: Text(
              "Error: ${state.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          final roomDetails = (state as dynamic).room;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Code Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Room Code",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            roomDetails.roomCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: roomDetails.roomCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          successSnackBar(
                            msg: 'Room code copied to clipboard!',
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      tooltip: 'Copy room code',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text("Name: ${roomDetails.name}"),
              Text("Creator: ${roomDetails.creatorId}"),
              Text("Capacity: ${roomDetails.capacity}"),
              Text("JoinedUsers: ${roomDetails.joinedUsers.length}"),
              Text("Work Duration: ${roomDetails.workDuration} mins"),
              Text("Break Duration: ${roomDetails.breakDuration} mins"),
              Text("Public: ${roomDetails.isPublic ? 'Yes' : 'No'}"),
              Text("Total Sessions: ${roomDetails.totalSessions}"),
              Text("CreatedAt: ${roomDetails.createdAt.toDate()}"),
              const SizedBox(height: 12),
              RoomPhaseTimer(
                createdAt: roomDetails.createdAt.toDate(),
                workDuration: roomDetails.workDuration,
                breakDuration: roomDetails.breakDuration,
                totalSessions: roomDetails.totalSessions,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
