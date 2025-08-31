import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';

class DailyStudyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's daily study time
  Future<Duration> getDailyStudyTime() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Duration.zero;

      final today = TimezoneUtils.getTodayDateString();
      final docRef = _firestore
          .collection(FirebaseConstants.dailyStatsCollection)
          .doc(user.uid)
          .collection('dates')
          .doc(today);

      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Duration(
          seconds: data[FirebaseConstants.totalStudyTimeField] ?? 0,
        );
      }
      return Duration.zero;
    } on Exception catch (e) {
      e;
      return Duration.zero;
    }
  }

  /// Add study time to today's total
  Future<void> addStudyTime(Duration studyTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = TimezoneUtils.getTodayDateString();
      final docRef = _firestore
          .collection(FirebaseConstants.dailyStatsCollection)
          .doc(user.uid)
          .collection('dates')
          .doc(today);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        final currentTime =
            doc.exists
                ? Duration(
                  seconds:
                      doc.data()![FirebaseConstants.totalStudyTimeField] ?? 0,
                )
                : Duration.zero;

        final newTotal = currentTime + studyTime;

        transaction.set(docRef, {
          FirebaseConstants.totalStudyTimeField: newTotal.inMinutes,
          'date': today,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      // Update user's total study time
      await _updateUserTotalStudyTime(studyTime);
    } on Exception catch (e) {
      e;
      // Error adding study time
    }
  }

  /// Update user's total study time
  Future<void> _updateUserTotalStudyTime(Duration studyTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(userRef);
        if (doc.exists) {
          final currentTotal = Duration(
            seconds: doc.data()![FirebaseConstants.totalStudyTimeField] ?? 0,
          );
          final newTotal = currentTotal + studyTime;

          transaction.update(userRef, {
            FirebaseConstants.totalStudyTimeField: newTotal.inSeconds,
            FirebaseConstants.lastStudyDateField:
                TimezoneUtils.getTodayDateString(),
          });
        }
      });
    } on Exception catch (e) {
      e;
      // Error updating user total study time
    }
  }

  /// Get study time for a specific date
  Future<Duration> getStudyTimeForDate(String date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Duration.zero;

      final docRef = _firestore
          .collection(FirebaseConstants.dailyStatsCollection)
          .doc(user.uid)
          .collection('dates')
          .doc(date);

      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Duration(
          seconds: data[FirebaseConstants.totalStudyTimeField] ?? 0,
        );
      }
      return Duration.zero;
    } on Exception catch (e) {
      e;
      return Duration.zero;
    }
  }

  /// Get study time for the last N days
  Future<Map<String, Duration>> getStudyTimeForLastDays(int days) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final Map<String, Duration> result = {};
      final now = DateTime.now();

      for (int i = 0; i < days; i++) {
        final date = DateTime(now.year, now.month, now.day - i);
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        final studyTime = await getStudyTimeForDate(dateString);
        result[dateString] = studyTime;
      }

      return result;
    } on Exception catch (e) {
      e;
      return {};
    }
  }

  /// Get study time for a specific month
  Future<Map<String, Duration>> getStudyTimeForMonth(
    int year,
    int month,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final Map<String, Duration> result = {};
      final daysInMonth = DateTime(year, month + 1, 0).day;

      for (int day = 1; day <= daysInMonth; day++) {
        final dateString =
            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final studyTime = await getStudyTimeForDate(dateString);
        result[dateString] = studyTime;
      }

      return result;
    } on Exception catch (e) {
      e;
      return {};
    }
  }

  /// Reset daily study time (useful for testing or manual reset)
  Future<void> resetDailyStudyTime() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = TimezoneUtils.getTodayDateString();
      final docRef = _firestore
          .collection(FirebaseConstants.dailyStatsCollection)
          .doc(user.uid)
          .collection('dates')
          .doc(today);

      await docRef.delete();
    } on Exception catch (e) {
      e;
      // Error resetting daily study time
    }
  }

  /// Get user's total study time across all days
  Future<Duration> getTotalStudyTime() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Duration.zero;

      final userRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid);

      final doc = await userRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Duration(
          seconds: data[FirebaseConstants.totalStudyTimeField] ?? 0,
        );
      }
      return Duration.zero;
    } on Exception catch (e) {
      e;
      return Duration.zero;
    }
  }

  /// Get study time for the last week (7 days)
  Future<int> getStudyStreakForLastWeek() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      int streakDays = 0;
      final now = DateTime.now();
      const minimumStudyTime = Duration(minutes: 45);

      // Get data for the last 7 days
      for (int i = 0; i < 7; i++) {
        final date = DateTime(now.year, now.month, now.day - i);
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        final studyTime = await getStudyTimeForDate(dateString);

        // Check if study time meets minimum requirement
        if (studyTime >= minimumStudyTime) {
          streakDays++;
        } else {
          // Break streak if a day is missed
          break;
        }
      }

      return streakDays;
    } on Exception catch (e) {
      e;
      return 0;
    }
  }
}
