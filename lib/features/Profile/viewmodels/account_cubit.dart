import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_states.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/repositories/AccountOPS_Repo.dart';

class AccountCubit extends Cubit<AccountStates> {
  AccountCubit(this.accountopsRepo) : super(AccountInitialState());

  AccountopsRepo accountopsRepo;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(AccountLoadingState());
    final User user = FirebaseAuth.instance.currentUser!;

    try {
      await accountopsRepo.authenticate(oldPassword, user);
      if (oldPassword == newPassword) {
        emit(SameOldPassword());
        return;
      }
      await user.updatePassword(newPassword);

      emit(PasswordSuccess());
      await Future.delayed(const Duration(seconds: 3), () {});
      emit(AccountInitialState());
    } on Exception catch (e, stackTrace) {
      e;
      stackTrace;
      emit(PasswordError('Error updating password: $e , $stackTrace'));
    }
  }

  Future<void> deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      emit(AccountLoadingState());

      await accountopsRepo.deleteAccount();

      emit(UserDeletionSuccess());
    } on Exception catch (error) {
      error;
      emit(UserDeletionError(error.toString()));
    }
  }

  Future<void> logout() async {
    try {
      emit(AccountLoadingState());

      await FirebaseAuth.instance.signOut();

      emit(LogoutSuccess());
    } on Exception catch (error) {
      error;
      emit(LogoutError(error.toString()));
    }
  }
}
