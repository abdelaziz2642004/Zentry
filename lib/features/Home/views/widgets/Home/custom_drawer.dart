import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/functions.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';

class Customdrawer extends StatelessWidget {
  const Customdrawer({super.key});

  void _showJoinByCodeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      failedSnackBar(
                        msg:
                            'Room not found, has finished, or was deleted : ${e.toString()}',
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
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Join by Code'),
            onTap: () {
              Navigator.of(context).pop();
              _showJoinByCodeDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
