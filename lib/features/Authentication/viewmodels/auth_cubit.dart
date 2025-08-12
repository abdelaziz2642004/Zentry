import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_states.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/repositories/auth_repo.dart';
import 'dart:io';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepo) : super(AuthInitialState());

  final AuthRepo authRepo;

  Future<void> login(String emailOrUsername, String password) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepo.login(emailOrUsername, password);
      emit(AuthSuccessState(user));
    } on Exception catch (e) {
      e;
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String fullName,
    File? profileImage,
  }) async {
    emit(AuthLoadingState());

    // Check username availability first
    final isUsernameAvailable = await authRepo.checkUsernameAvailability(
      username,
    );
    if (!isUsernameAvailable) {
      emit(AuthErrorState('Username already exists'));
      return;
    }

    try {
      await authRepo.signUp(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        profileImage: profileImage,
      );
      emit(AuthSuccessState(null));
    } on Exception catch (e) {
      e;
      emit(AuthErrorState(e.toString()));
    }
  }

  void checkUsernameAvailability(String userName) async {
    emit(AuthLoadingState());

    final isAvailable = await authRepo.checkUsernameAvailability(userName);
    if (!isAvailable) {
      emit(AuthErrorState('Username already exists'));
    } else {
      emit(AuthSuccessState(null));
    }
  }
}
