import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class CreateGroupActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CreateGroupActions({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        const SizedBox(width: 8),
        BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, state) {
            final isLoading = state is GroupCreatingState;

            return ElevatedButton(
              onPressed: !isLoading ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text('Create Group'),
            );
          },
        ),
      ],
    );
  }
}
