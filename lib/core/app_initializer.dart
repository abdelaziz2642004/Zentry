import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:zentry_pomodoro_app/core/get_it.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';

/// Handles all app initialization logic
class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    setUpLocator();

    // Initialize timezone utilities
    TimezoneUtils.getUserTimezone(); // This will initialize the timezone system
  }
}
