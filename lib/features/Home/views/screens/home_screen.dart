import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Home/views/screens/create_room_bottom_sheet.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_button.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/custom_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/custom_drawer.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/recently_joined.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/rooms_grid_builder.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/daily_time_tracker.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';

import 'package:zentry_pomodoro_app/core/functions.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfUserShouldJoin();
    });
  }

  Future<void> _checkIfUserShouldJoin() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      final roomCubit = BlocProvider.of<RoomCubit>(context);
      final navigator = Navigator.of(context);
      final roomCode = await roomCubit.atStart(user);

      if (roomCode != "" && mounted) {
        navigator.push(
          MaterialPageRoute(
            builder:
                (_) => BlocProvider<RoomCubit>.value(
                  value: roomCubit,
                  child: RoomScreen(roomCode: roomCode),
                ),
          ),
        );
      }
    }
  }

  void _showJoinByCodeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Join Room by Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the 6-digit room code:'),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: '123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();

                if (!isValidRoomCode(code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    failedSnackBar(msg: 'Please enter a valid 6-digit code'),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Joining room...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                try {
                  final roomCubit = BlocProvider.of<RoomCubit>(context);

                  // Check if already joining
                  if (roomCubit.state is RoomJoinLoadingState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      failedSnackBar(
                        msg: 'Already joining a room. Please wait.',
                      ),
                    );
                    return;
                  }

                  final navigator = Navigator.of(context);
                  await roomCubit.joinRoom(code);

                  // Navigate to room screen
                  if (context.mounted) {
                    navigator.push(
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider.value(
                              value: roomCubit,
                              child: RoomScreen(roomCode: code),
                            ),
                      ),
                    );
                  }
                } on Exception catch (e) {
                  e;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      failedSnackBar(
                        msg: 'Room not found, has finished, or was deleted',
                      ),
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomCubit = BlocProvider.of<RoomCubit>(context);
    return Scaffold(
      drawer: const Customdrawer(),
      appBar: Customappbar.build(context),
      backgroundColor: white,
      body: SafeArea(
        child: BlocBuilder<RoomCubit, RoomStates>(
          buildWhen: (previous, current) {
            // Return true only for the specific states you want to rebuild for
            return current is RoomLoadingState || current is RoomInitialState;
          },
          builder: (context, state) {
            if (state is RoomLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Timetrackertoday(),
                  const SizedBox(height: 24),
                  const Recentlyjoined(),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Public Rooms",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CustomButton(
                        onTap: () => _showJoinByCodeDialog(context),
                        content: const Text(
                          "Join by Code",
                          style: TextStyle(color: white, fontSize: 12),
                        ),
                        bgColor: mainColor,
                        hPadding: 12,
                        vPadding: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const RoomsGridBuilder(),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Avatar & Creator",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder:
                (BuildContext ctx) => BlocProvider<RoomCubit>.value(
                  value: roomCubit,
                  child: const CreateRoom(),
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
