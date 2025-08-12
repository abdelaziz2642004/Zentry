import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';

class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final FireUser? user;
  AuthSuccessState(this.user);
}

class AuthErrorState extends AuthState {
  final String error;
  AuthErrorState(this.error);
}
