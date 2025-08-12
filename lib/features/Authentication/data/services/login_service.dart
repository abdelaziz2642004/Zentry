import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

/// Result class for login operations
class LoginResult {
  final bool isSuccess;
  final String? error;
  final FireUser? user;

  LoginResult._({required this.isSuccess, this.error, this.user});

  factory LoginResult.success([FireUser? user]) {
    return LoginResult._(isSuccess: true, user: user);
  }

  factory LoginResult.failure(String error) {
    return LoginResult._(isSuccess: false, error: error);
  }
}

/// Clean login service - only business logic and data access, no UI
class LoginService {
  LoginService();

  /// Authenticate user with email/username and password
  Future<LoginResult> signIn(String emailOrUsername, String password) async {
    try {
      String input = emailOrUsername.trim();

      // Handle username lookup
      if (!input.contains('@')) {
        final snapshot =
            await FirebaseFirestore.instance
                .collection(FirebaseConstants.userNamesCollection)
                .doc(input)
                .get();

        if (snapshot.exists) {
          input = snapshot.data()![FirebaseConstants.emailField];
        } else {
          return LoginResult.failure('Username not found');
        }
      }

      // Authenticate with Firebase
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: input, password: password.trim());

      // Get the user ID from Firebase Auth
      final String userId = userCredential.user!.uid;

      // Update session
      final String sessionID = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({FirebaseConstants.sessionIdField: sessionID});

      // Store session in SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("SessionID", sessionID);

      return LoginResult.success();
    } on Exception catch (e) {
      e;
      return LoginResult.failure(e.toString());
    }
  }

  /// Validate login form data
  String? validateLoginForm(String emailOrUsername, String password) {
    if (emailOrUsername.isEmpty) {
      return 'Email or username cannot be empty';
    }

    if (password.isEmpty) {
      return 'Password cannot be empty';
    }

    return null;
  }
}
