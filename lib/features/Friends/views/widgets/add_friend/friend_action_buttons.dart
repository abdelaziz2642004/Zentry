import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/loading_utils.dart';

class FriendActionButtons extends StatelessWidget {
  final String? selectedUserId;
  final bool isCheckingRequest;
  final bool isAlreadyFriends;
  final bool hasExistingRequest;
  final VoidCallback? onCancel;
  final VoidCallback? onAcceptRequest;
  final VoidCallback? onSendRequest;

  const FriendActionButtons({
    super.key,
    required this.selectedUserId,
    required this.isCheckingRequest,
    required this.isAlreadyFriends,
    required this.hasExistingRequest,
    required this.onCancel,
    required this.onAcceptRequest,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendRequestsCubit, FriendsState>(
      builder: (context, state) {
        final isLoading = state is FriendsLoadingState;
        final isDisabled =
            selectedUserId == null || isLoading || isCheckingRequest;

        // Use utility functions for button logic
        final buttonText = LoadingUtils.getButtonText(
          isCheckingRequest: isCheckingRequest,
          isAlreadyFriends: isAlreadyFriends,
          hasExistingRequest: hasExistingRequest,
        );

        final buttonAction = LoadingUtils.getButtonAction(
          isCheckingRequest: isCheckingRequest,
          isAlreadyFriends: isAlreadyFriends,
          hasExistingRequest: hasExistingRequest,
          isDisabled: isDisabled,
          onAcceptRequest: onAcceptRequest,
          onSendRequest: onSendRequest,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isDisabled || isAlreadyFriends ? null : buttonAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoadingUtils.getButtonColor(
                  isAlreadyFriends: isAlreadyFriends,
                  hasExistingRequest: hasExistingRequest,
                  defaultColor: mainColor,
                ),
                foregroundColor: Colors.white,
              ),
              child: _buildButtonChild(
                isCheckingRequest,
                isLoading,
                buttonText,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonChild(
    bool isCheckingRequest,
    bool isLoading,
    String buttonText,
  ) {
    if (isCheckingRequest || isLoading) {
      return LoadingUtils.buildButtonLoader(color: Colors.white);
    } else {
      return Text(buttonText);
    }
  }
}
