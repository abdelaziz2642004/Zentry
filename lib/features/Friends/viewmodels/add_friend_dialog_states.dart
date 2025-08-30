abstract class AddFriendDialogState {
  const AddFriendDialogState();
}

class AddFriendDialogInitial extends AddFriendDialogState {
  const AddFriendDialogInitial() : super();
}

class AddFriendDialogSearching extends AddFriendDialogState {
  const AddFriendDialogSearching() : super();
}

class AddFriendDialogSearchResults extends AddFriendDialogState {
  final List<Map<String, dynamic>> searchResults;
  final String? selectedUserId;

  const AddFriendDialogSearchResults({
    required this.searchResults,
    this.selectedUserId,
  }) : super();
}

class AddFriendDialogCheckingStatus extends AddFriendDialogState {
  final String userId;
  final List<Map<String, dynamic>> searchResults;

  const AddFriendDialogCheckingStatus({
    required this.userId,
    required this.searchResults,
  }) : super();
}

class AddFriendDialogUserSelected extends AddFriendDialogState {
  final String selectedUserId;
  final List<Map<String, dynamic>> searchResults;
  final bool isAlreadyFriends;
  final bool hasExistingRequest;

  const AddFriendDialogUserSelected({
    required this.selectedUserId,
    required this.searchResults,
    required this.isAlreadyFriends,
    required this.hasExistingRequest,
  }) : super();
}

class AddFriendDialogSendingRequest extends AddFriendDialogState {
  final String selectedUserId;
  final List<Map<String, dynamic>> searchResults;
  final bool isAlreadyFriends;
  final bool hasExistingRequest;

  const AddFriendDialogSendingRequest({
    required this.selectedUserId,
    required this.searchResults,
    required this.isAlreadyFriends,
    required this.hasExistingRequest,
  }) : super();
}

class AddFriendDialogAcceptingRequest extends AddFriendDialogState {
  final String selectedUserId;
  final List<Map<String, dynamic>> searchResults;

  const AddFriendDialogAcceptingRequest({
    required this.selectedUserId,
    required this.searchResults,
  }) : super();
}

class AddFriendDialogSuccess extends AddFriendDialogState {
  final String message;

  const AddFriendDialogSuccess({required this.message}) : super();
}

class AddFriendDialogError extends AddFriendDialogState {
  final String error;
  final AddFriendDialogState? previousState;

  const AddFriendDialogError({required this.error, this.previousState})
    : super();
}
