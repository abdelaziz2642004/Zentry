import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class AtStartService {
  static Future<FireUser> fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return FireUser();
      }

      final String fireUserId = currentUser.uid;
      final DocumentSnapshot fireUserDoc =
          await FirebaseFirestore.instance
              .collection(FirebaseConstants.usersCollection)
              .doc(fireUserId)
              .get();

      if (!fireUserDoc.exists) {
        return FireUser();
      }

      final String sessionID = fireUserDoc[FirebaseConstants.sessionIdField];
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final oldSessionID = prefs.getString('SessionID');

      if (oldSessionID != sessionID) {
        // Update SharedPreferences with the new session ID instead of logging out
        await prefs.setString('SessionID', sessionID);
      }

      return FireUser(
        notifications: [],
        id: fireUserId,
        email: fireUserDoc[FirebaseConstants.emailField] ?? '',
        imageUrl: fireUserDoc[FirebaseConstants.imageUrlField] ?? '',
        fullName: fireUserDoc[FirebaseConstants.fullNameField] ?? '',
      );
    } catch (e) {
      throw Exception("Error fetching FireUser: $e");
    }
  }
}
