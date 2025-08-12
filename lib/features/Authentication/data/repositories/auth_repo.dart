import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/services/login_service.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/services/sign_up_service.dart';
import 'dart:io';

class AuthRepo {
  late LoginService loginService;
  late SignupService signupService;

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String fullName,
    File? profileImage,
  }) async {
    final result = await signupService.signUp(
      email: email,
      username: username,
      password: password,
      fullName: fullName,
      profileImage: profileImage,
    );

    if (result.isSuccess) {
      // if successful, then log out because I don't want the signup to be as login
      await FirebaseAuth.instance.signOut();
    } else {
      throw Exception(result.error);
    }
  }

  Future<FireUser?> login(String emailOrUsername, String password) async {
    final result = await loginService.signIn(emailOrUsername, password);
    if (result.isSuccess) {
      return result.user;
    } else {
      throw Exception(result.error);
    }
  }

  Future<bool> checkUsernameAvailability(String userName) async {
    if (userName.isEmpty) {
      return true;
    }
    return await signupService.isUsernameAvailable(userName);
  }
}
