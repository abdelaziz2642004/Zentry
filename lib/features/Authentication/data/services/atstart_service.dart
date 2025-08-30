import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/online_status_service.dart';

class AtStartService {
  static final OnlineStatusService _onlineStatusService = OnlineStatusService();

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

      final userData = fireUserDoc.data() as Map<String, dynamic>;

      return FireUser(
        notifications: [],
        id: fireUserId,
        email: userData[FirebaseConstants.emailField] ?? '',
        imageUrl: userData[FirebaseConstants.imageUrlField] ?? '',
        fullName: userData[FirebaseConstants.fullNameField] ?? '',
        timezone: userData[FirebaseConstants.timezoneField] ?? 'UTC',
        timezoneOffset: userData[FirebaseConstants.timezoneOffsetField] ?? 0,
        dailyStudyHours: Duration(
          seconds: userData[FirebaseConstants.dailyStudyHoursField] ?? 0,
        ),
        lastStudyDate: userData[FirebaseConstants.lastStudyDateField] ?? '',
        totalStudyTime: Duration(
          seconds: userData[FirebaseConstants.totalStudyTimeField] ?? 0,
        ),
      );

      // Set user as online
      await _onlineStatusService.setUserOnline();

      final user = FireUser(
        notifications: [],
        id: fireUserId,
        email: userData[FirebaseConstants.emailField] ?? '',
        imageUrl: userData[FirebaseConstants.imageUrlField] ?? '',
        fullName: userData[FirebaseConstants.fullNameField] ?? '',
        timezone: userData[FirebaseConstants.timezoneField] ?? 'UTC',
        timezoneOffset: userData[FirebaseConstants.timezoneOffsetField] ?? 0,
        dailyStudyHours: Duration(
          seconds: userData[FirebaseConstants.dailyStudyHoursField] ?? 0,
        ),
        lastStudyDate: userData[FirebaseConstants.lastStudyDateField] ?? '',
        totalStudyTime: Duration(
          seconds: userData[FirebaseConstants.totalStudyTimeField] ?? 0,
        ),
      );

      return user;
    } catch (e) {
      throw Exception("Error fetching FireUser: $e");
    }
  }
}
