import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_container.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/control_badge.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/creator_info.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/join_button.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/joined_users.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/room_name.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/session_info.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/tags.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/Helping%20Widgets/work_break_view.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';

class RoomGridItem extends StatelessWidget {
  final PomodoroRoom room;

  const RoomGridItem({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      builder: (context, state) {
        // Get the updated room data if available, otherwise use the original
        final PomodoroRoom currentRoom = room;
        // if (state is RoomJoinSuccess && state.room.roomCode == room.roomCode) {
        //   currentRoom = state.room;
        // }

        final List<String> tags = currentRoom.tags;
        final String roomName = currentRoom.name;
        final bool isPublic = currentRoom.isPublic;
        final String workTime = "${currentRoom.workDuration} min";
        final String breakTime = "${currentRoom.breakDuration} min";
        final String creatorId = currentRoom.creatorId;
        final int joinedUsers = currentRoom.joinedUsers.length;
        final int roomCapacity = currentRoom.capacity;
        final int numberOfSessions = currentRoom.totalSessions;

        return Stack(
          children: [
            CustomContainer(
              color: Colors.white,
              blurRadius: 4,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 18,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Room Name
                    RoomName(roomName: roomName),
                    const SizedBox(height: 4),

                    /// Creator Info
                    CreatorInfo(creatorId: creatorId),
                    const SizedBox(height: 8),

                    /// Sessions Info
                    SessionInfo(
                      numberOfSessions: numberOfSessions,
                      workDuration: currentRoom.workDuration,
                      breakDuration: currentRoom.breakDuration,
                      createdAt: currentRoom.createdAt,
                    ),
                    const SizedBox(height: 12),

                    /// Work & Break Time
                    WorkBreakView(
                      time: workTime,
                      icon: Icons.work,
                      iconColor: Colors.blueAccent,
                      title: "Work Time: ",
                    ),
                    const SizedBox(height: 4),
                    WorkBreakView(
                      time: breakTime,
                      icon: Icons.coffee,
                      iconColor: Colors.orange,
                      title: "Break Time: ",
                    ),

                    /// Tags
                    Tags(tags: tags),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Joined Users
                        JoinedUsers(
                          joinedUsers: joinedUsers,
                          roomCapacity: roomCapacity,
                        ),
                        const SizedBox(width: 15),

                        /// Join Button
                        JoinButton(roomId: currentRoom.roomCode),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// Control Badge
            ControlBadge(isPublic: isPublic),
          ],
        );
      },
    );
  }
}
