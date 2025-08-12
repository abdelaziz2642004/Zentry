import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';

class CreateButton extends StatelessWidget {
  const CreateButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      buildWhen: (previous, current) {
        // Return true only for the specific states you want to rebuild for
        return current is RoomCreatingLoadingState ||
            current is RoomCreationFailure ||
            current is RoomCreationSuccess;
      },
      builder: (context, state) {
        final isLoading = state is RoomCreatingLoadingState;
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Create', style: TextStyle(color: white)),
          ),
        );
      },
    );
  }
}
