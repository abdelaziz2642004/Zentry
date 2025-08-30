import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class GroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new study group
  Future<String> createGroup({
    required String name,
    required String description,
    required bool isPublic,
    required int maxMembers,
    required List<String> tags,
    required String category,
    String? imageUrl,
    String? password, // Add password for private groups
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

    // Create the group
    final groupRef = await _firestore.collection('studyGroups').add({
      'name': name,
      'description': description,
      'creatorId': currentUser.uid,
      'creatorName': currentUserData[FirebaseConstants.fullNameField],
      'creatorImageUrl': currentUserData[FirebaseConstants.imageUrlField] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'isPublic': isPublic,
      'maxMembers': maxMembers,
      'memberIds': [currentUser.uid], // Creator is automatically a member
      'adminIds': [currentUser.uid], // Creator is automatically an admin
      'tags': tags,
      'category': category,
      'imageUrl': imageUrl ?? '',
      'messageCount': 0,
      'lastActivity': FieldValue.serverTimestamp(),
      'password': password, // Store password for private groups
    });

    // Add group to user's joined groups
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('joinedGroups')
        .doc(groupRef.id)
        .set({'joinedAt': FieldValue.serverTimestamp(), 'role': 'admin'});

    return groupRef.id;
  }

  /// Get all groups (both public and private) for discovery
  Stream<List<StudyGroup>> getPublicGroups() {
    return _firestore
        .collection('studyGroups')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => StudyGroup.fromMap(doc.data(), doc.id))
                  .toList()
                ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity)),
        );
  }

  /// Get groups by category (both public and private)
  Stream<List<StudyGroup>> getGroupsByCategory(String category) {
    return _firestore
        .collection('studyGroups')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => StudyGroup.fromMap(doc.data(), doc.id))
                  .where((group) => group.category == category)
                  .toList()
                ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity)),
        );
  }

  /// Search groups by name or tags (both public and private)
  Future<List<StudyGroup>> searchGroups(String query) async {
    if (query.trim().isEmpty) return [];

    final snapshot = await _firestore.collection('studyGroups').get();

    final allGroups =
        snapshot.docs
            .map((doc) => StudyGroup.fromMap(doc.data(), doc.id))
            .toList();

    final queryLower = query.trim().toLowerCase();
    final results = <StudyGroup>[];

    for (final group in allGroups) {
      // Search by name
      if (group.name.toLowerCase().contains(queryLower)) {
        results.add(group);
        continue;
      }

      // Search by tags
      if (group.tags.any((tag) => tag.toLowerCase().contains(queryLower))) {
        results.add(group);
        continue;
      }
    }

    // Remove duplicates and limit results
    final uniqueResults = <String, StudyGroup>{};
    for (final group in results) {
      uniqueResults[group.id] = group;
    }

    return uniqueResults.values.take(10).toList();
  }

  /// Join a group
  Future<void> joinGroup(String groupId, {String? password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get group data
    final groupDoc =
        await _firestore.collection('studyGroups').doc(groupId).get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupDoc.data()!;
    final memberIds = List<String>.from(groupData['memberIds'] ?? []);

    // Check if already a member
    if (memberIds.contains(currentUser.uid)) {
      throw Exception('Already a member of this group');
    }

    // Check if group is full
    if (memberIds.length >= groupData['maxMembers']) {
      throw Exception('Group is full');
    }

    // Check if group is private and password is required
    final isPublic = groupData['isPublic'] ?? true;
    final groupPassword = groupData['password'];

    if (!isPublic && groupPassword != null) {
      if (password == null || password != groupPassword) {
        throw Exception('Password required to join this private group');
      }
    }

    // Add user to group members
    memberIds.add(currentUser.uid);
    await _firestore.collection('studyGroups').doc(groupId).update({
      'memberIds': memberIds,
      'lastActivity': FieldValue.serverTimestamp(),
    });

    // Add group to user's joined groups
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('joinedGroups')
        .doc(groupId)
        .set({'joinedAt': FieldValue.serverTimestamp(), 'role': 'member'});
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    print('User ${currentUser.uid} attempting to leave group $groupId');

    // Get group data
    final groupDoc =
        await _firestore.collection('studyGroups').doc(groupId).get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupDoc.data()!;
    final memberIds = List<String>.from(groupData['memberIds'] ?? []);
    final adminIds = List<String>.from(groupData['adminIds'] ?? []);
    final creatorId = groupData['creatorId'];

    print(
      'Group $groupId - Creator: $creatorId, Members: $memberIds, Admins: $adminIds',
    );

    // Check if user is a member
    if (!memberIds.contains(currentUser.uid)) {
      throw Exception('Not a member of this group');
    }

    // Remove user from members
    memberIds.remove(currentUser.uid);
    adminIds.remove(currentUser.uid);

    print('After removal - Members: $memberIds, Admins: $adminIds');

    // Only delete the group if there are no members left
    if (memberIds.isEmpty) {
      print('No members left, deleting group $groupId');
      await _firestore.collection('studyGroups').doc(groupId).delete();
    } else {
      // If the creator left but there are still members, promote the first member to admin
      if (creatorId == currentUser.uid &&
          adminIds.isEmpty &&
          memberIds.isNotEmpty) {
        final promotedMember = memberIds.first;
        adminIds.add(promotedMember);
        print('Creator left, promoting $promotedMember to admin');
      }

      print(
        'Updating group $groupId with members: $memberIds, admins: $adminIds',
      );

      // Update group
      await _firestore.collection('studyGroups').doc(groupId).update({
        'memberIds': memberIds,
        'adminIds': adminIds,
        'lastActivity': FieldValue.serverTimestamp(),
      });
    }

    // Remove group from user's joined groups
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('joinedGroups')
        .doc(groupId)
        .delete();

    print('User ${currentUser.uid} successfully left group $groupId');
  }

  /// Get user's joined groups
  Stream<List<StudyGroup>> getUserJoinedGroups() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('joinedGroups')
        .snapshots()
        .asyncMap((snapshot) async {
          final groups = <StudyGroup>[];
          for (final doc in snapshot.docs) {
            final groupDoc =
                await _firestore.collection('studyGroups').doc(doc.id).get();

            if (groupDoc.exists) {
              groups.add(StudyGroup.fromMap(groupDoc.data()!, groupDoc.id));
            }
          }
          return groups;
        });
  }

  /// Get group details
  Future<StudyGroup?> getGroupDetails(String groupId) async {
    final doc = await _firestore.collection('studyGroups').doc(groupId).get();

    if (!doc.exists) return null;
    return StudyGroup.fromMap(doc.data()!, doc.id);
  }

  /// Check if user is a member of a group
  Future<bool> isUserMember(String groupId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final doc =
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('joinedGroups')
            .doc(groupId)
            .get();

    return doc.exists;
  }

  /// Check if user is an admin of a group
  Future<bool> isUserAdmin(String groupId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final groupDoc =
        await _firestore.collection('studyGroups').doc(groupId).get();

    if (!groupDoc.exists) return false;

    final groupData = groupDoc.data()!;
    final adminIds = List<String>.from(groupData['adminIds'] ?? []);
    return adminIds.contains(currentUser.uid);
  }

  /// Add member as admin
  Future<void> addAdmin(String groupId, String memberId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if current user is admin
    final isAdmin = await isUserAdmin(groupId);
    if (!isAdmin) {
      throw Exception('Only admins can add other admins');
    }

    final groupDoc =
        await _firestore.collection('studyGroups').doc(groupId).get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupDoc.data()!;
    final adminIds = List<String>.from(groupData['adminIds'] ?? []);

    if (!adminIds.contains(memberId)) {
      adminIds.add(memberId);
      await _firestore.collection('studyGroups').doc(groupId).update({
        'adminIds': adminIds,
        'lastActivity': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Remove admin
  Future<void> removeAdmin(String groupId, String memberId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if current user is admin
    final isAdmin = await isUserAdmin(groupId);
    if (!isAdmin) {
      throw Exception('Only admins can remove other admins');
    }

    final groupDoc =
        await _firestore.collection('studyGroups').doc(groupId).get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupDoc.data()!;
    final adminIds = List<String>.from(groupData['adminIds'] ?? []);

    // Don't remove the creator
    if (groupData['creatorId'] == memberId) {
      throw Exception('Cannot remove the group creator from admins');
    }

    adminIds.remove(memberId);
    await _firestore.collection('studyGroups').doc(groupId).update({
      'adminIds': adminIds,
      'lastActivity': FieldValue.serverTimestamp(),
    });
  }

  /// Update group last activity
  Future<void> updateGroupActivity(String groupId) async {
    await _firestore.collection('studyGroups').doc(groupId).update({
      'lastActivity': FieldValue.serverTimestamp(),
    });
  }
}
