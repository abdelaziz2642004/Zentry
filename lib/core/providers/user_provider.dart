import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class UserProvider extends ChangeNotifier {
  FireUser? _user;

  FireUser? get user => _user;

  void setUser(FireUser? user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  /// Update user's timezone information
  Future<void> updateUserTimezone() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final timezone = TimezoneUtils.getUserTimezone();
      final timezoneOffset = TimezoneUtils.getUserTimezoneOffset();

      // Update user model if it exists
      if (_user != null) {
        _user!.updateTimezone(timezone, timezoneOffset);
      }

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update({
            FirebaseConstants.timezoneField: timezone,
            FirebaseConstants.timezoneOffsetField: timezoneOffset,
          });

      notifyListeners();
    } on Exception catch (e) {
      e;
      // Error updating user timezone
    }
  }

  /// Update user's daily study hours
  void updateDailyStudyHours(Duration studyTime) {
    if (_user != null) {
      _user!.updateDailyStudyHours(studyTime);
      notifyListeners();
    }
  }

  /// Update user's total study time
  void updateTotalStudyTime(Duration studyTime) {
    if (_user != null) {
      _user!.updateTotalStudyTime(studyTime);
      notifyListeners();
    }
  }

  /// Update user's last study date
  void updateLastStudyDate(String date) {
    if (_user != null) {
      _user!.updateLastStudyDate(date);
      notifyListeners();
    }
  }
}
