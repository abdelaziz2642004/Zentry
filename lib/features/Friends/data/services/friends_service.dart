import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend_request.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friend_code_service.dart';

class FriendsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final BlockService _blockService = BlockService();
  final FriendCodeService _friendCodeService = FriendCodeService();

  /// Send a friend request
  Future<void> sendFriendRequest({
    required String receiverUsername,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get current user data
    final currentUserDoc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .get();

    if (!currentUserDoc.exists) {
      throw Exception('Current user data not found');
    }

    final currentUserData = currentUserDoc.data()!;

    // Get receiver user data by username
    final receiverDoc =
        await _firestore
            .collection(FirebaseConstants.userNamesCollection)
            .doc(receiverUsername.trim())
            .get();

    if (!receiverDoc.exists) {
      throw Exception('User not found');
    }

    final receiverData = receiverDoc.data()!;
    final receiverId = receiverData[FirebaseConstants.idField];

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      currentUser.uid,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot send friend request - user is blocked or has blocked you',
      );
    }

    // Check if already friends
    final areFriends = await checkIfFriends(currentUser.uid, receiverId);
    if (areFriends) {
      throw Exception('Already friends');
    }

    // Check if request already exists
    final existingRequest = await _checkExistingRequest(
      currentUser.uid,
      receiverId,
    );
    if (existingRequest) {
      throw Exception('Friend request already sent');
    }

    // Create friend request
    await _firestore.collection('friendRequests').add({
      'senderId': currentUser.uid,
      'senderName': currentUserData[FirebaseConstants.fullNameField],
      'senderUsername': currentUserData[FirebaseConstants.usernameField],
      'senderImageUrl': currentUserData[FirebaseConstants.imageUrlField] ?? '',
      'receiverId': receiverId,
      'receiverName': receiverData[FirebaseConstants.fullNameField],
      'receiverUsername': receiverData[FirebaseConstants.usernameField],
      'receiverImageUrl': receiverData[FirebaseConstants.imageUrlField] ?? '',
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send a friend request by user ID (alternative to username method)
  Future<void> sendFriendRequestById({
    required String receiverId,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    if (currentUser.uid == receiverId) {
      throw Exception('Cannot send friend request to yourself');
    }

    // Get current user data
    final currentUserDoc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .get();

    if (!currentUserDoc.exists) {
      throw Exception('Current user data not found');
    }

    final currentUserData = currentUserDoc.data()!;

    // Get receiver user data by ID
    final receiverDoc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(receiverId)
            .get();

    if (!receiverDoc.exists) {
      throw Exception('Receiver user not found');
    }

    final receiverData = receiverDoc.data()!;

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      currentUser.uid,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot send friend request - user is blocked or has blocked you',
      );
    }

    // Check if already friends
    final areFriends = await checkIfFriends(currentUser.uid, receiverId);
    if (areFriends) {
      throw Exception('Already friends');
    }

    // Check if request already exists from current user to receiver
    final existingRequest = await _checkExistingRequest(
      currentUser.uid,
      receiverId,
    );
    if (existingRequest) {
      throw Exception('Friend request already sent');
    }

    // Check if request already exists from receiver to current user (mutual friend request logic)
    final reverseRequest = await _checkExistingRequest(
      receiverId,
      currentUser.uid,
    );
    if (reverseRequest) {
      // If both users sent requests to each other, automatically make them friends
      await _handleMutualFriendRequest(currentUser.uid, receiverId);
      return;
    }

    // Create friend request
    await _firestore.collection('friendRequests').add({
      'senderId': currentUser.uid,
      'senderName': currentUserData[FirebaseConstants.fullNameField],
      'senderUsername': currentUserData[FirebaseConstants.usernameField],
      'senderImageUrl': currentUserData[FirebaseConstants.imageUrlField] ?? '',
      'receiverId': receiverId,
      'receiverName': receiverData[FirebaseConstants.fullNameField],
      'receiverUsername': receiverData[FirebaseConstants.usernameField],
      'receiverImageUrl': receiverData[FirebaseConstants.imageUrlField] ?? '',
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Handle mutual friend requests - automatically make users friends
  Future<void> _handleMutualFriendRequest(
    String userId1,
    String userId2,
  ) async {
    try {
      // Find and update the existing request from user2 to user1
      final existingRequestQuery =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: userId2)
              .where('receiverId', isEqualTo: userId1)
              .where('status', isEqualTo: 'pending')
              .get();

      if (existingRequestQuery.docs.isNotEmpty) {
        final requestDoc = existingRequestQuery.docs.first;

        // Update the existing request to accepted
        await requestDoc.reference.update({
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
          'mutualRequest': true,
        });

        // Add both users to each other's friends list
        await _addToFriendsList(userId1, userId2);

        print('Mutual friend request detected - users are now friends');
      }
    } catch (e) {
      print('Error handling mutual friend request: $e');
      throw Exception('Error processing mutual friend request');
    }
  }

  /// Get pending friend requests for current user (filtered to exclude blocked users)
  Stream<List<FriendRequest>> getPendingFriendRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          final requests =
              snapshot.docs
                  .map((doc) => FriendRequest.fromMap(doc.data(), doc.id))
                  .where(
                    (request) => request.status == FriendRequestStatus.pending,
                  )
                  .toList();

          // Filter out requests from blocked users
          final filteredRequests = <FriendRequest>[];
          for (final request in requests) {
            final canInteract = await _blockService.canUsersInteract(
              request.senderId,
              request.receiverId,
            );
            if (canInteract) {
              filteredRequests.add(request);
            }
          }

          filteredRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return filteredRequests;
        });
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final requestDoc =
        await _firestore.collection('friendRequests').doc(requestId).get();

    if (!requestDoc.exists) {
      throw Exception('Friend request not found');
    }

    final requestData = requestDoc.data()!;
    final senderId = requestData['senderId'];
    final receiverId = requestData['receiverId'];

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      senderId,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot accept friend request - user is blocked or has blocked you',
      );
    }

    // Update request status
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // Add to friends list for both users
    await _addToFriendsList(senderId, receiverId);
  }

  /// Reject a friend request
  Future<void> rejectFriendRequest(String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final requestDoc =
        await _firestore.collection('friendRequests').doc(requestId).get();

    if (!requestDoc.exists) {
      throw Exception('Friend request not found');
    }

    final requestData = requestDoc.data()!;
    final senderId = requestData['senderId'];
    final receiverId = requestData['receiverId'];

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      senderId,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot reject friend request - user is blocked or has blocked you',
      );
    }

    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get current user's friends list with real-time online status (filtered to exclude blocked users)
  Stream<List<Friend>> getFriendsList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    print('Getting friends list for user: ${currentUser.uid}');

    return _firestore
        .collection('friends')
        .doc(currentUser.uid)
        .collection('friendsList')
        .snapshots()
        .asyncMap((snapshot) async {
          final friends = <Friend>[];
          final friendIds = snapshot.docs.map((doc) => doc.id).toList();

          if (friendIds.isEmpty) return friends;

          // Get blocked users list
          final blockedUsersSnapshot =
              await _firestore
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('blockedUsers')
                  .get();
          final blockedUserIds =
              blockedUsersSnapshot.docs.map((doc) => doc.id).toSet();

          // Filter out blocked users
          final nonBlockedFriendIds =
              friendIds.where((id) => !blockedUserIds.contains(id)).toList();

          if (nonBlockedFriendIds.isEmpty) return friends;

          // Get all user data in parallel
          final userDocs = await Future.wait(
            nonBlockedFriendIds.map(
              (id) =>
                  _firestore
                      .collection(FirebaseConstants.usersCollection)
                      .doc(id)
                      .get(),
            ),
          );

          // Get all online statuses in parallel
          final onlineStatuses = await Future.wait(
            nonBlockedFriendIds.map(
              (id) => _database.child('users').child(id).child('online').get(),
            ),
          );

          // Get all last seen timestamps in parallel
          final lastSeenTimestamps = await Future.wait(
            nonBlockedFriendIds.map(
              (id) =>
                  _database.child('users').child(id).child('lastSeen').get(),
            ),
          );

          for (int i = 0; i < nonBlockedFriendIds.length; i++) {
            final userDoc = userDocs[i];
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final friendId = nonBlockedFriendIds[i];

              // Get online status
              final onlineStatusSnapshot = onlineStatuses[i];
              bool isOnline = false;
              if (onlineStatusSnapshot.exists &&
                  onlineStatusSnapshot.value != null) {
                isOnline = onlineStatusSnapshot.value == true;
              }

              // Get last seen
              final lastSeenSnapshot = lastSeenTimestamps[i];
              DateTime lastSeen = DateTime.now();
              if (lastSeenSnapshot.exists && lastSeenSnapshot.value != null) {
                if (lastSeenSnapshot.value is int) {
                  lastSeen = DateTime.fromMillisecondsSinceEpoch(
                    lastSeenSnapshot.value as int,
                  );
                }
              }

              print(
                'User $friendId online status: $isOnline, lastSeen: $lastSeen',
              );

              friends.add(
                Friend.fromMap({
                  'id': friendId,
                  'username': userData[FirebaseConstants.usernameField],
                  'fullName': userData[FirebaseConstants.fullNameField],
                  'email': userData[FirebaseConstants.emailField],
                  'imageUrl': userData[FirebaseConstants.imageUrlField] ?? '',
                  'status': isOnline ? 'online' : 'offline',
                  'lastSeen': lastSeen,
                  'isOnline': isOnline,
                  'totalStudyTime': userData['totalStudyTime'] ?? 0,
                  'dailyStudyTime': userData['dailyStudyTime'] ?? 0,
                  'lastStudyDate': userData['lastStudyDate'] ?? '',
                  'favoriteSubjects': userData['favoriteSubjects'] ?? [],
                }),
              );
            }
          }
          return friends;
        });
  }

  /// Get current user's friends list with real-time online status (simplified version)
  Stream<List<Friend>> getFriendsListSimple() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    print('Getting friends list (simple) for user: ${currentUser.uid}');

    return _firestore
        .collection('friends')
        .doc(currentUser.uid)
        .collection('friendsList')
        .snapshots()
        .asyncMap((snapshot) async {
          final friends = <Friend>[];
          final friendIds = snapshot.docs.map((doc) => doc.id).toList();

          if (friendIds.isEmpty) return friends;

          // Get all user data in parallel
          final userDocs = await Future.wait(
            friendIds.map(
              (id) =>
                  _firestore
                      .collection(FirebaseConstants.usersCollection)
                      .doc(id)
                      .get(),
            ),
          );

          // Get all online statuses in parallel
          final onlineStatuses = await Future.wait(
            friendIds.map(
              (id) => _database.child('users').child(id).child('online').get(),
            ),
          );

          // Get all last seen timestamps in parallel
          final lastSeenTimestamps = await Future.wait(
            friendIds.map(
              (id) =>
                  _database.child('users').child(id).child('lastSeen').get(),
            ),
          );

          for (int i = 0; i < friendIds.length; i++) {
            final userDoc = userDocs[i];
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final friendId = friendIds[i];

              // Get online status
              final onlineStatusSnapshot = onlineStatuses[i];
              bool isOnline = false;
              if (onlineStatusSnapshot.exists &&
                  onlineStatusSnapshot.value != null) {
                isOnline = onlineStatusSnapshot.value == true;
              }

              // Get last seen
              final lastSeenSnapshot = lastSeenTimestamps[i];
              DateTime lastSeen = DateTime.now();
              if (lastSeenSnapshot.exists && lastSeenSnapshot.value != null) {
                if (lastSeenSnapshot.value is int) {
                  lastSeen = DateTime.fromMillisecondsSinceEpoch(
                    lastSeenSnapshot.value as int,
                  );
                }
              }

              print(
                'User $friendId online status: $isOnline, lastSeen: $lastSeen',
              );

              friends.add(
                Friend.fromMap({
                  'id': friendId,
                  'username': userData[FirebaseConstants.usernameField],
                  'fullName': userData[FirebaseConstants.fullNameField],
                  'email': userData[FirebaseConstants.emailField],
                  'imageUrl': userData[FirebaseConstants.imageUrlField] ?? '',
                  'status': isOnline ? 'online' : 'offline',
                  'lastSeen': lastSeen,
                  'isOnline': isOnline,
                  'totalStudyTime': userData['totalStudyTime'] ?? 0,
                  'dailyStudyTime': userData['dailyStudyTime'] ?? 0,
                  'lastStudyDate': userData['lastStudyDate'] ?? '',
                  'favoriteSubjects': userData['favoriteSubjects'] ?? [],
                }),
              );
            }
          }
          return friends;
        });
  }

  /// Remove a friend
  Future<void> removeFriend(String friendId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Remove from both users' friends lists
    await _firestore
        .collection('friends')
        .doc(currentUser.uid)
        .collection('friendsList')
        .doc(friendId)
        .delete();

    await _firestore
        .collection('friends')
        .doc(friendId)
        .collection('friendsList')
        .doc(currentUser.uid)
        .delete();
  }

  /// Search for users by username (excluding blocked users)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    // Search by username (partial match)
    final snapshot =
        await _firestore
            .collection(FirebaseConstants.userNamesCollection)
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: query.trim())
            .where(FieldPath.documentId, isLessThan: '${query.trim()}\uf8ff')
            .limit(10)
            .get();

    final users = <Map<String, dynamic>>[];
    for (final doc in snapshot.docs) {
      final userData = doc.data();
      final userId = userData[FirebaseConstants.idField];

      if (userId != currentUser.uid) {
        // Check if user is blocked
        final isBlocked = await _blockService.isUserBlocked(userId);
        final isBlockedByUser = await _blockService.isBlockedByUser(userId);

        // Only add user if neither has blocked the other
        if (!isBlocked && !isBlockedByUser) {
          users.add({
            'id': userId,
            'username': doc.id,
            'fullName': userData[FirebaseConstants.fullNameField],
            'imageUrl': userData[FirebaseConstants.imageUrlField] ?? '',
          });
        }
      }
    }

    return users;
  }

  /// Search user by friend code
  Future<Map<String, dynamic>?> searchUserByFriendCode(String code) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    if (code.trim().isEmpty) return null;

    try {
      final userData = await _friendCodeService.findUserByFriendCode(
        code.trim(),
      );

      if (userData != null && userData['id'] != currentUser.uid) {
        // Check if user is blocked
        final isBlocked = await _blockService.isUserBlocked(userData['id']);
        final isBlockedByUser = await _blockService.isBlockedByUser(
          userData['id'],
        );

        // Only return user if neither has blocked the other
        if (!isBlocked && !isBlockedByUser) {
          return userData;
        }
      }

      return null;
    } catch (e) {
      print('Error searching user by friend code: $e');
      return null;
    }
  }

  /// Check if two users are friends
  Future<bool> checkIfFriends(String userId1, String userId2) async {
    final doc =
        await _firestore
            .collection('friends')
            .doc(userId1)
            .collection('friendsList')
            .doc(userId2)
            .get();

    return doc.exists;
  }

  /// Check if a friend request already exists
  Future<bool> _checkExistingRequest(String senderId, String receiverId) async {
    final snapshot =
        await _firestore
            .collection('friendRequests')
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: receiverId)
            .get();

    return snapshot.docs
        .map((doc) => FriendRequest.fromMap(doc.data(), doc.id))
        .any((request) => request.status == FriendRequestStatus.pending);
  }

  /// Add two users to each other's friends list
  Future<void> _addToFriendsList(String userId1, String userId2) async {
    final batch = _firestore.batch();

    // Add user2 to user1's friends list
    final user1FriendRef = _firestore
        .collection('friends')
        .doc(userId1)
        .collection('friendsList')
        .doc(userId2);

    batch.set(user1FriendRef, {
      'addedAt': FieldValue.serverTimestamp(),
      'status': 'offline',
      'lastSeen': FieldValue.serverTimestamp(),
    });

    // Add user1 to user2's friends list
    final user2FriendRef = _firestore
        .collection('friends')
        .doc(userId2)
        .collection('friendsList')
        .doc(userId1);

    batch.set(user2FriendRef, {
      'addedAt': FieldValue.serverTimestamp(),
      'status': 'offline',
      'lastSeen': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Get blocked users list
  Stream<List<Map<String, dynamic>>> getBlockedUsers() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUsers = <Map<String, dynamic>>[];

          for (final doc in snapshot.docs) {
            final userDoc =
                await _firestore
                    .collection(FirebaseConstants.usersCollection)
                    .doc(doc.id)
                    .get();

            if (userDoc.exists) {
              final userData = userDoc.data()!;
              blockedUsers.add({
                'id': doc.id,
                'username': userData[FirebaseConstants.usernameField],
                'fullName': userData[FirebaseConstants.fullNameField],
                'imageUrl': userData[FirebaseConstants.imageUrlField] ?? '',
                'blockedAt': doc.data()['blockedAt'],
              });
            }
          }

          return blockedUsers;
        });
  }

  /// Check if a friend request is already sent
  Future<bool> checkIfFriendRequestSent(
    String? senderId,
    String receiverId,
  ) async {
    if (senderId == null) return false;

    try {
      final query =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: senderId)
              .where('receiverId', isEqualTo: receiverId)
              .where('status', isEqualTo: 'pending')
              .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking friend request status: $e');
      return false;
    }
  }

  /// Check if a friend request was received from someone (and users can interact)
  Future<bool> checkIfFriendRequestReceived(
    String? receiverId,
    String senderId,
  ) async {
    if (receiverId == null) return false;

    try {
      final query =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: senderId)
              .where('receiverId', isEqualTo: receiverId)
              .where('status', isEqualTo: 'pending')
              .get();

      if (query.docs.isEmpty) return false;

      // Check if users can interact (not blocked)
      final canInteract = await _blockService.canUsersInteract(
        senderId,
        receiverId,
      );

      return canInteract;
    } catch (e) {
      print('Error checking received friend request status: $e');
      return false;
    }
  }

  /// Get friend request ID by sender and receiver
  Future<String?> getFriendRequestId(String senderId, String receiverId) async {
    try {
      final query =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: senderId)
              .where('receiverId', isEqualTo: receiverId)
              .where('status', isEqualTo: 'pending')
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting friend request ID: $e');
      return null;
    }
  }

  /// Check if there's any pending friend request between two users (in either direction)
  Future<bool> checkIfAnyFriendRequestPending(
    String userId1,
    String userId2,
  ) async {
    try {
      // Check if user1 sent a request to user2
      final query1 =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: userId1)
              .where('receiverId', isEqualTo: userId2)
              .where('status', isEqualTo: 'pending')
              .get();

      if (query1.docs.isNotEmpty) return true;

      // Check if user2 sent a request to user1
      final query2 =
          await _firestore
              .collection('friendRequests')
              .where('senderId', isEqualTo: userId2)
              .where('receiverId', isEqualTo: userId1)
              .where('status', isEqualTo: 'pending')
              .get();

      return query2.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if any friend request is pending: $e');
      return false;
    }
  }

  /// Get real-time friendship status between two users
  Stream<Map<String, bool>> getFriendshipStatusStream(
    String userId1,
    String userId2,
  ) {
    // Listen to both friendship status and friend requests in real-time
    return _firestore
        .collection('friendRequests')
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .snapshots()
        .asyncMap((requestsSnapshot) async {
          // Check friendship status
          final friendshipDoc =
              await _firestore
                  .collection('friends')
                  .doc(userId1)
                  .collection('friendsList')
                  .doc(userId2)
                  .get();

          final isFriend = friendshipDoc.exists;

          // Check for pending friend requests
          final pendingRequests =
              requestsSnapshot.docs
                  .where((doc) => doc.data()['status'] == 'pending')
                  .toList();

          final hasPendingRequest = pendingRequests.isNotEmpty;

          return {'isFriend': isFriend, 'hasPendingRequest': hasPendingRequest};
        });
  }

  /// Get detailed real-time friendship status between two users
  Stream<Map<String, dynamic>> getDetailedFriendshipStatusStream(
    String userId1,
    String userId2,
  ) {
    return _firestore
        .collection('friendRequests')
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .snapshots()
        .asyncMap((requestsSnapshot) async {
          // Check friendship status
          final friendshipDoc =
              await _firestore
                  .collection('friends')
                  .doc(userId1)
                  .collection('friendsList')
                  .doc(userId2)
                  .get();

          final isFriend = friendshipDoc.exists;

          // Check for pending friend requests and their direction
          final pendingRequests =
              requestsSnapshot.docs
                  .where((doc) => doc.data()['status'] == 'pending')
                  .toList();

          final hasPendingRequest = pendingRequests.isNotEmpty;
          bool isRequestSent = false;
          bool isRequestReceived = false;

          if (hasPendingRequest) {
            for (final request in pendingRequests) {
              final data = request.data();
              if (data['senderId'] == userId1 &&
                  data['receiverId'] == userId2) {
                isRequestSent = true;
              } else if (data['senderId'] == userId2 &&
                  data['receiverId'] == userId1) {
                isRequestReceived = true;
              }
            }
          }

          return {
            'isFriend': isFriend,
            'hasPendingRequest': hasPendingRequest,
            'isRequestSent': isRequestSent,
            'isRequestReceived': isRequestReceived,
          };
        });
  }
}
