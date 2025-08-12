import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';

class SessionManager extends ChangeNotifier {
  StreamSubscription<DocumentSnapshot>? _sessionSubscription;
  bool _isSessionValid = true;
  BuildContext? _globalContext;

  bool get isSessionValid => _isSessionValid;

  SessionManager() {
    // Always start listening if user is already logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Use a microtask to ensure context is available
      Future.microtask(() {
        if (_globalContext != null) {
          _startListening(_globalContext!);
        }
      });
    }
  }

  // Store a global context reference for session listener
  void setContext(BuildContext context) {
    _globalContext = context;
  }

  Future<void> handleLogin(BuildContext context) async {
    setContext(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final sessionID = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .update({FirebaseConstants.sessionIdField: sessionID});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('SessionID', sessionID);
    _startListening(context);
  }

  // void handleLogout() {
  //   _stopListening();
  //   _isSessionValid = true;
  //   notifyListeners();
  //   // Optionally, restart listener if user logs in again
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null && _globalContext != null) {
  //     _startListening(_globalContext);
  //   }
  // }

  void _startListening(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;
    final prefs = await SharedPreferences.getInstance();

    _sessionSubscription?.cancel();
    _sessionSubscription = FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists) return;
          final remoteSessionId = snapshot[FirebaseConstants.sessionIdField];
          final currentLocalSessionId = prefs.getString('SessionID');
          if (remoteSessionId != currentLocalSessionId) {
            // Session ID changed: log out and show message
            await FirebaseAuth.instance.signOut();

            // Check if context is still valid before using it
            final currentContext = _globalContext;
            if (currentContext != null && currentContext.mounted) {
              Provider.of<UserProvider>(
                currentContext,
                listen: false,
              ).clearUser();
              ScaffoldMessenger.of(currentContext).showSnackBar(
                failedSnackBar(
                  msg: 'oh oh a new device logged in from the same account',
                  title: 'Session Conflict',
                ),
              );
            }

            await prefs.remove('SessionID');
            _isSessionValid = false;
            notifyListeners();
            _stopListening();
          }
        });
  }

  void _stopListening() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
