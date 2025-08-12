import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_button.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';

import '../../../../../../core/colors.dart';

class JoinButton extends StatelessWidget {
  const JoinButton({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      builder: (context, state) {
        final isJoining = state is RoomJoinLoadingState;

        return CustomButton(
          hPadding: 8,
          onTap:
              isJoining
                  ? () {}
                  : () {
                    final roomCubit = BlocProvider.of<RoomCubit>(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider.value(
                              value: roomCubit,
                              child: RoomScreen(roomCode: roomId),
                            ),
                      ),
                    );
                  },
          content:
              isJoining
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(white),
                    ),
                  )
                  : const Icon(Icons.play_arrow, color: white, size: 22),
          bgColor: isJoining ? Colors.grey : mainColor,
        );
      },
    );
  }
}
