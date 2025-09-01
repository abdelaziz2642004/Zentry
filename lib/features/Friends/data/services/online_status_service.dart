import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class OnlineStatusService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  DatabaseReference? _userStatusRef;
  DatabaseReference? _userLastSeenRef;

  /// Set user as online and configure onDisconnect
  Future<void> setUserOnline() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('No authenticated user found for setting online status');
      return;
    }

    print('Setting user ${user.uid} as online...');

    _userStatusRef = _database.child('users').child(user.uid).child('online');
    _userLastSeenRef = _database
        .child('users')
        .child(user.uid)
        .child('lastSeen');

    try {
      // Set user as online
      await _userStatusRef!.set(true);
      print('User ${user.uid} online status set to true');

      // Set last seen to current time
      await _userLastSeenRef!.set(ServerValue.timestamp);
      print('User ${user.uid} last seen updated');

      // Configure onDisconnect to set online to false and update lastSeen
      await _userStatusRef!.onDisconnect().set(false);
      await _userLastSeenRef!.onDisconnect().set(ServerValue.timestamp);

      print('User ${user.uid} set as online with onDisconnect configured');

      // Verify the status was set correctly
      final statusSnapshot = await _userStatusRef!.get();
      print(
        'Verification - User ${user.uid} online status: ${statusSnapshot.value}',
      );
    } catch (e) {
      print('Error setting user online: $e');
      rethrow;
    }
  }

  /// Manually set user as offline (when logging out)
  Future<void> setUserOffline() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('No authenticated user found for setting offline status');
      return;
    }

    try {
      // Cancel onDisconnect listeners
      if (_userStatusRef != null) {
        await _userStatusRef!.onDisconnect().cancel();
      }
      if (_userLastSeenRef != null) {
        await _userLastSeenRef!.onDisconnect().cancel();
      }

      // Set user as offline
      await _database.child('users').child(user.uid).child('online').set(false);
      await _database
          .child('users')
          .child(user.uid)
          .child('lastSeen')
          .set(ServerValue.timestamp);

      print('User ${user.uid} set as offline');
    } catch (e) {
      print('Error setting user offline: $e');
      rethrow;
    }
  }

  /// Get stream of user's online status
  Stream<bool> getUserOnlineStatus(String userId) {
    return _database.child('users').child(userId).child('online').onValue.map((
      event,
    ) {
      final value = event.snapshot.value;
      return value == true;
    });
  }

  /// Get stream of user's last seen timestamp
  Stream<DateTime?> getUserLastSeen(String userId) {
    return _database.child('users').child(userId).child('lastSeen').onValue.map(
      (event) {
        final value = event.snapshot.value;
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        }
        return null;
      },
    );
  }

  /// Get combined online status and last seen for a user
  Stream<Map<String, dynamic>> getUserStatus(String userId) {
    return _database.child('users').child(userId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {'online': false, 'lastSeen': null};

      final online = data['online'] == true;
      final lastSeen = data['lastSeen'];

      DateTime? lastSeenTime;
      if (lastSeen is int) {
        lastSeenTime = DateTime.fromMillisecondsSinceEpoch(lastSeen);
      }

      return {'online': online, 'lastSeen': lastSeenTime};
    });
  }
}
