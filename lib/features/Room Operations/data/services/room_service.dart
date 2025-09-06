import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/functions.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

class RoomService {
  Future<PomodoroRoom?> recentlyFetch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final DatabaseReference userRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getUserPath(user.uid),
    );

    final DataSnapshot recentSnapshot = await userRef.child("recently").get();
    if (!recentSnapshot.exists) return null;

    final String recentRoomCode = recentSnapshot.value as String;

    // Fetch Firestore room metadata
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.roomsCollection)
            .doc(recentRoomCode)
            .get();

    if (!doc.exists) return null;

    // Fetch current users from RTDB (may be empty)
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getRoomUsersPath(recentRoomCode),
    );
    final DataSnapshot usersSnap = await usersRef.get();
    final List<String> users = <String>[];
    if (usersSnap.exists && usersSnap.value is Map) {
      final Map<dynamic, dynamic> usersMap =
          usersSnap.value as Map<dynamic, dynamic>;
      users.addAll(usersMap.keys.map((k) => k.toString()));
    }

    return PomodoroRoom.fromDocumentWithUsers(doc, users);
  }

  Future<String?> joinedRoomFetch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final DatabaseReference userRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getUserPath(user.uid),
    );

    final DataSnapshot joinedSnapshot = await userRef.child("joinedroom").get();

    if (joinedSnapshot.exists) {
      final String roomCode = joinedSnapshot.value as String;

      return roomCode;
    } else {
      return "";
    }
  }

  Future<void> createRoom(PomodoroRoom room) async {
    try {
      // Generate a unique 6-digit room code
      final uniqueRoomCode = await generateUniqueRoomCode();
      room.setRoomCode(uniqueRoomCode);

      // Write room metadata to Firestore only
      final DocumentReference<Map<String, dynamic>> roomDoc = FirebaseFirestore
          .instance
          .collection(FirebaseConstants.roomsCollection)
          .doc(room.roomCode);

      await roomDoc.set(room.toMap());

      // Ensure RTDB users node exists (optional - can be lazy created on join)
      // final DatabaseReference usersRef = FirebaseDatabase.instance.ref(
      //   FirebaseConstants.getRoomUsersPath(room.roomCode),
      // );
      // await usersRef.set({});
    } catch (e) {
      rethrow;
    }
  }

  /// Enhanced join room with better presence tracking
  Future<PomodoroRoom?> joinRoom(String roomCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Validate room exists in Firestore
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.roomsCollection)
            .doc(roomCode)
            .get();

    if (!doc.exists) {
      return null;
    }

    // Add user to RTDB users list for the room
    final DatabaseReference userRef = FirebaseDatabase.instance
        .ref(FirebaseConstants.getRoomUsersPath(roomCode))
        .child(user.uid);

    // Set user as present and remove on disconnect
    await userRef.set(true);
    await userRef.onDisconnect().remove();

    // Add joined room to Realtime Database under users/{userID}/joinedroom
    final userDbRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getUserPath(user.uid),
    );

    // Set the recently joined room in Realtime Database (persistent)
    await userDbRef.child("recently").set(roomCode);

    // Set the joined room in Realtime Database (disconnectable)
    await userDbRef.child("joinedroom").set(roomCode);
    await userDbRef.child("joinedroom").onDisconnect().remove();

    // Build current users list
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getRoomUsersPath(roomCode),
    );
    final DataSnapshot usersSnap = await usersRef.get();
    final List<String> users = <String>[];
    if (usersSnap.exists && usersSnap.value is Map) {
      final Map<dynamic, dynamic> usersMap =
          usersSnap.value as Map<dynamic, dynamic>;
      users.addAll(usersMap.keys.map((k) => k.toString()));
    }

    final PomodoroRoom room = PomodoroRoom.fromDocumentWithUsers(doc, users);

    return room;
  }

  Future<void> leaveRoom(String roomCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Remove user from RTDB users list
    final DatabaseReference userRef = FirebaseDatabase.instance
        .ref(FirebaseConstants.getRoomUsersPath(roomCode))
        .child(user.uid);
    await userRef.remove();

    // Remove joined room from Realtime Database under users/{userID}/joinedroom
    final userDbRef = FirebaseDatabase.instance.ref(
      FirebaseConstants.getUserPath(user.uid),
    );
    await userDbRef.child("joinedroom").remove();
  }

  /// Fetch all public rooms from Firestore
  Future<List<PomodoroRoom>> fetchAllPublicRooms() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection(FirebaseConstants.roomsCollection)
              .where('Public', isEqualTo: true)
              .where('availableRoom', isEqualTo: true)
              .get();

      final List<PomodoroRoom> rooms = [];

      for (final doc in snapshot.docs) {
        final room = PomodoroRoom.fromDocument(doc);

        // Skip finished rooms
        if (!room.isFinished) {
          // Fetch current users from RTDB for each room
          final DatabaseReference usersRef = FirebaseDatabase.instance.ref(
            FirebaseConstants.getRoomUsersPath(room.roomCode),
          );
          final DataSnapshot usersSnap = await usersRef.get();
          final List<String> users = <String>[];

          if (usersSnap.exists && usersSnap.value is Map) {
            final Map<dynamic, dynamic> usersMap =
                usersSnap.value as Map<dynamic, dynamic>;
            users.addAll(usersMap.keys.map((k) => k.toString()));
          }

          // Create room with current users
          final roomWithUsers = PomodoroRoom.fromDocumentWithUsers(doc, users);
          rooms.add(roomWithUsers);
        }
      }

      return rooms;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of all public rooms from Firestore
  Stream<List<PomodoroRoom>> streamPublicRooms() {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.roomsCollection)
        .where('Public', isEqualTo: true)
        .where('availableRoom', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<PomodoroRoom> rooms = [];

          for (final doc in snapshot.docs) {
            final room = PomodoroRoom.fromDocument(doc);

            // Skip finished rooms
            if (!room.isFinished) {
              // Fetch current users from RTDB for each room
              final DatabaseReference usersRef = FirebaseDatabase.instance.ref(
                FirebaseConstants.getRoomUsersPath(room.roomCode),
              );
              final DataSnapshot usersSnap = await usersRef.get();
              final List<String> users = <String>[];

              if (usersSnap.exists && usersSnap.value is Map) {
                final Map<dynamic, dynamic> usersMap =
                    usersSnap.value as Map<dynamic, dynamic>;
                users.addAll(usersMap.keys.map((k) => k.toString()));
              }

              // Create room with current users
              final roomWithUsers = PomodoroRoom.fromDocumentWithUsers(
                doc,
                users,
              );
              rooms.add(roomWithUsers);
            }
          }

          return rooms;
        });
  }
}
