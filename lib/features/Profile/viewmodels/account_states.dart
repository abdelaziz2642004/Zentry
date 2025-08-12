class AccountStates {}

class AccountInitialState extends AccountStates {}

class AccountLoadingState extends AccountStates {}

class PasswordSuccess extends AccountStates {}

class SameOldPassword extends AccountStates {}

class PasswordError extends AccountStates {
  final String error;
  PasswordError(this.error);
}

class UserDeletionSuccess extends AccountStates {}

class UserDeletionError extends AccountStates {
  final String error;
  UserDeletionError(this.error);
}

class LogoutSuccess extends AccountStates {}

class LogoutError extends AccountStates {
  final String error;
  LogoutError(this.error);
}
