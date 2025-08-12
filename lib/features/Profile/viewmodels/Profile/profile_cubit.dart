import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/repositories/Profile_Repo.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit(this.profileRepo) : super(ProfileInitialState());

  final ProfileRepo profileRepo;

  Future<void> changeImage(File pickedFile) async {
    emit(ProfileLoadingState());
    try {
      final String imageurl = await profileRepo.changeImage(pickedFile);
      emit(ProfileImageSuccessState(imageurl));
    } on Exception catch (error) {
      emit(ProfileErrorState(error.toString()));
    }
  }

  Future<void> changeFullName(String newName) async {
    emit(ProfileLoadingState());
    try {
      await profileRepo.changeFullName(newName);
      emit(FullNameSuccessState());
    } on Exception catch (e) {
      e;
      emit(FullNameErrorState('Error updating full name: $e'));
    }
  }
}
