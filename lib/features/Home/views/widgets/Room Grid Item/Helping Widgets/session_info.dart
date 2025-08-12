import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SessionInfo extends StatefulWidget {
  final Timestamp createdAt;
  final int workDuration;
  final int breakDuration;
  final int numberOfSessions;

  const SessionInfo({
    super.key,
    required this.createdAt,
    required this.workDuration,
    required this.breakDuration,
    required this.numberOfSessions,
  });

  @override
  State<SessionInfo> createState() => _SessionInfoState();
}

class _SessionInfoState extends State<SessionInfo> {
  int currentSession = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    updateCurrentSession();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateCurrentSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateCurrentSession() {
    final now = DateTime.now().toUtc(); // Use UTC for consistency
    final createdAt = widget.createdAt.toDate().toUtc(); // Convert to UTC
    final elapsed = now.difference(createdAt);
    final elapsedMinutes = elapsed.inMinutes;

    final fullCycle = widget.workDuration + widget.breakDuration;

    final cyclesPassed = elapsedMinutes ~/ fullCycle;

    // Calculate current session (1-based)
    final session = cyclesPassed + 1;

    // Check if all sessions are finished
    if (session > widget.numberOfSessions) {
      setState(() {
        currentSession = widget.numberOfSessions;
      });
      _timer?.cancel();
      return;
    }

    setState(() {
      currentSession = cyclesPassed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "Session $currentSession/${widget.numberOfSessions}",
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }
}

/// Utility class to check if a room has finished all sessions
class RoomSessionUtils {
  /// Check if a room has finished all its sessions
  static bool isRoomFinished({
    required Timestamp createdAt,
    required int workDuration,
    required int breakDuration,
    required int numberOfSessions,
  }) {
    final now = DateTime.now();
    final createdAtDate = createdAt.toDate();
    final elapsed = now.difference(createdAtDate);
    final elapsedMinutes = elapsed.inMinutes;

    final fullCycle = workDuration + breakDuration;
    final cyclesPassed = elapsedMinutes ~/ fullCycle;

    // Calculate current session (1-based)
    final session = cyclesPassed + 1;

    // Room is finished if current session exceeds total sessions
    return session > numberOfSessions;
  }

  /// Get the current session number for a room
  static int getCurrentSession({
    required Timestamp createdAt,
    required int workDuration,
    required int breakDuration,
    required int numberOfSessions,
  }) {
    final now = DateTime.now();
    final createdAtDate = createdAt.toDate();
    final elapsed = now.difference(createdAtDate);
    final elapsedMinutes = elapsed.inMinutes;

    final fullCycle = workDuration + breakDuration;
    final cyclesPassed = elapsedMinutes ~/ fullCycle;

    // Calculate current session (1-based)
    final session = cyclesPassed + 1;

    // Return the current session, capped at total sessions
    return session > numberOfSessions ? numberOfSessions : session;
  }
}

/// Example Cloud Function to automatically remove finished rooms
/// Add this to your Firebase Functions (functions/index.js):
/*
exports.cleanupFinishedRooms = functions.pubsub
  .schedule('every 10 minutes')
  .onRun(async (context) => {
    const admin = require('firebase-admin');
    const db = admin.database();
    const roomsRef = db.ref('Rooms');
    
    try {
      const roomsSnapshot = await roomsRef.once('value');
      if (!roomsSnapshot.exists()) return null;
      
      const rooms = roomsSnapshot.val();
      const currentTime = Date.now();
      const roomsToRemove = [];
      
      for (const [roomCode, roomData] of Object.entries(rooms)) {
        const createdAt = roomData.createdAt;
        const workDuration = roomData.workDuration || 25;
        const breakDuration = roomData.breakDuration || 5;
        const numberOfSessions = roomData.numberOfSessions || 1;
        
        const elapsedMinutes = (currentTime - createdAt) / (1000 * 60);
        const fullCycle = workDuration + breakDuration;
        const cyclesPassed = Math.floor(elapsedMinutes / fullCycle);
        const session = cyclesPassed + 1;
        
        // Remove room if all sessions are finished
        if (session > numberOfSessions) {
          roomsToRemove.push(roomCode);
        }
      }
      
      // Remove finished rooms
      for (const roomCode of roomsToRemove) {
        await roomsRef.child(roomCode).remove();
      }
      
      console.log(`Removed ${roomsToRemove.length} finished rooms`);
      
    } catch (error) {
      console.error('Error cleaning up finished rooms:', error);
    }
    
    return null;
  });
*/
