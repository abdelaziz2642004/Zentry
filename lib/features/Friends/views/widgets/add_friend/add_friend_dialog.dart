import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/add_friend_dialog_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/add_friend_dialog_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/add_friend/friend_search_field.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/add_friend/user_result_list.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/add_friend/friend_message_input.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/add_friend/friend_action_buttons.dart';

class AddFriendDialog extends StatelessWidget {
  const AddFriendDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddFriendDialogCubit>(
      create: (context) => AddFriendDialogCubit(),
      child: const _AddFriendDialogContent(),
    );
  }
}

class _AddFriendDialogContent extends StatefulWidget {
  const _AddFriendDialogContent();

  @override
  State<_AddFriendDialogContent> createState() =>
      _AddFriendDialogContentState();
}

class _AddFriendDialogContentState extends State<_AddFriendDialogContent> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<AddFriendDialogCubit>().searchUsers(query);
  }

  void _onUserSelected(String userId) {
    context.read<AddFriendDialogCubit>().selectUser(userId);
  }

  void _onSendRequest() {
    final cubit = context.read<AddFriendDialogCubit>();
    final selectedUserId = cubit.getCurrentSelectedUserId();
    if (selectedUserId != null) {
      cubit.sendFriendRequest(_messageController.text);
    }
  }

  void _onAcceptRequest() {
    context.read<AddFriendDialogCubit>().acceptExistingRequest();
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddFriendDialogCubit, AddFriendDialogState>(
      builder: (context, state) {
        // Handle state changes
        if (state is AddFriendDialogSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFFD9F5F0)),
                ),
                backgroundColor: const Color(0xFF2CACAD),
              ),
            );
            Navigator.of(context).pop();
          });
        } else if (state is AddFriendDialogError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(color: Color(0xFFD9F5F0)),
                ),
                backgroundColor: const Color(0xFF072E33),
              ),
            );
          });
        }

        return AlertDialog(
          backgroundColor: const Color(0xFF05161A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Text(
            'Add Friend',
            style: TextStyle(
              color: const Color(0xFFD9F5F0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF05161A).withOpacity(0.9),
                  const Color(0xFF072E33).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FriendSearchField(
                    controller: _searchController,
                    isLoading: state is AddFriendDialogSearching,
                    onSearchChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 16),
                  Flexible(child: _buildSearchResults(state)),
                  _buildMessageInput(state),
                  const SizedBox(height: 20),
                  _buildActionButtons(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(AddFriendDialogState state) {
    final cubit = context.read<AddFriendDialogCubit>();
    final searchResults = cubit.getCurrentSearchResults();
    final selectedUserId = cubit.getCurrentSelectedUserId();

    if (state is AddFriendDialogSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return UserResultList(
      searchResults: searchResults,
      selectedUserId: selectedUserId,
      isLoading: state is AddFriendDialogSearching,
      onUserSelected: _onUserSelected,
    );
  }

  Widget _buildMessageInput(AddFriendDialogState state) {
    final cubit = context.read<AddFriendDialogCubit>();
    final selectedUserId = cubit.getCurrentSelectedUserId();

    return FriendMessageInput(
      controller: _messageController,
      showInput: selectedUserId != null,
    );
  }

  Widget _buildActionButtons(AddFriendDialogState state) {
    final cubit = context.read<AddFriendDialogCubit>();
    final selectedUserId = cubit.getCurrentSelectedUserId();

    bool isAlreadyFriends = false;
    bool hasExistingRequest = false;

    if (state is AddFriendDialogUserSelected) {
      isAlreadyFriends = state.isAlreadyFriends;
      hasExistingRequest = state.hasExistingRequest;
    } else if (state is AddFriendDialogSendingRequest) {
      isAlreadyFriends = state.isAlreadyFriends;
      hasExistingRequest = state.hasExistingRequest;
    }

    final isCheckingRequest = state is AddFriendDialogCheckingStatus;
    final isSendingRequest = state is AddFriendDialogSendingRequest;
    final isAcceptingRequest = state is AddFriendDialogAcceptingRequest;

    return FriendActionButtons(
      selectedUserId: selectedUserId,
      isCheckingRequest: isCheckingRequest,
      isAlreadyFriends: isAlreadyFriends,
      hasExistingRequest: hasExistingRequest,
      onCancel: _onCancel,
      onAcceptRequest: hasExistingRequest ? _onAcceptRequest : null,
      onSendRequest: _onSendRequest,
    );
  }
}
