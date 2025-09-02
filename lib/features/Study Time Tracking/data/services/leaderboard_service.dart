import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';

/// Leaderboard entry without username for privacy
class LeaderboardEntry {
  final String userId;
  final String fullName;
  final String? imageUrl;
  final Duration studyTime;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.fullName,
    this.imageUrl,
    required this.studyTime,
    required this.rank,
  });
}

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get today's leaderboard sorted by study time (limited to top 50)
  Future<List<LeaderboardEntry>> getTodayLeaderboard() async {
    try {
      final today = TimezoneUtils.getTodayDateString();

      // Get all users with their today's study time
      final usersSnapshot =
          await _firestore.collection(FirebaseConstants.usersCollection).get();

      final List<LeaderboardEntry> leaderboard = [];

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userId = userDoc.id;

        // Get today's study time for this user
        final studyTimeDoc =
            await _firestore
                .collection(FirebaseConstants.dailyStatsCollection)
                .doc(userId)
                .collection('dates')
                .doc(today)
                .get();

        Duration studyTime = Duration.zero;
        if (studyTimeDoc.exists) {
          final data = studyTimeDoc.data() as Map<String, dynamic>;
          // Data is stored in minutes, convert to Duration
          final studyTimeMinutes =
              data[FirebaseConstants.totalStudyTimeField] ?? 0;
          studyTime = Duration(minutes: studyTimeMinutes);
        }

        // Only include users who have studied today
        if (studyTime.inMinutes > 0) {
          leaderboard.add(
            LeaderboardEntry(
              userId: userId,
              fullName:
                  userData[FirebaseConstants.fullNameField] ?? 'Unknown User',
              imageUrl: userData[FirebaseConstants.imageUrlField],
              studyTime: studyTime,
              rank: 0, // Will be set after sorting
            ),
          );
        }
      }

      // Sort by study time (descending)
      leaderboard.sort((a, b) => b.studyTime.compareTo(a.studyTime));

      // Assign ranks and limit to top 50
      final topLeaderboard = <LeaderboardEntry>[];
      for (int i = 0; i < leaderboard.length && i < 50; i++) {
        topLeaderboard.add(
          LeaderboardEntry(
            userId: leaderboard[i].userId,
            fullName: leaderboard[i].fullName,
            imageUrl: leaderboard[i].imageUrl,
            studyTime: leaderboard[i].studyTime,
            rank: i + 1,
          ),
        );
      }

      return topLeaderboard;
    } on Exception catch (e) {
      e;
      return [];
    }
  }

  /// Get current user's rank in today's leaderboard
  Future<int> getCurrentUserRank() async {
    try {
      final leaderboard = await getTodayLeaderboard();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) return 0;

      final userEntry = leaderboard.firstWhere(
        (entry) => entry.userId == currentUserId,
        orElse:
            () => LeaderboardEntry(
              userId: '',
              fullName: '',
              studyTime: Duration.zero,
              rank: 0,
            ),
      );

      return userEntry.rank;
    } on Exception catch (e) {
      e;
      return 0;
    }
  }

  /// Get study time for a specific user on a specific date
  Future<Duration> getUserStudyTimeForDate(String userId, String date) async {
    try {
      final docRef = _firestore
          .collection(FirebaseConstants.dailyStatsCollection)
          .doc(userId)
          .collection('dates')
          .doc(date);

      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Data is stored in minutes, convert to Duration
        final studyTimeMinutes =
            data[FirebaseConstants.totalStudyTimeField] ?? 0;
        return Duration(minutes: studyTimeMinutes);
      }
      return Duration.zero;
    } on Exception catch (e) {
      e;
      return Duration.zero;
    }
  }

  /// Get a stream of user data for real-time updates
  Stream<Map<String, dynamic>?> getUserDataStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }
}
