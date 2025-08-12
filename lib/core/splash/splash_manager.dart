import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/services/atstart_service.dart';
import 'package:zentry_pomodoro_app/core/navigation/app_navigator.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/screens/splash_screen.dart';

/// Manages splash screen logic and initial user data fetching
class SplashManager extends StatefulWidget {
  const SplashManager({super.key});

  @override
  State<SplashManager> createState() => _SplashManagerState();
}

class _SplashManagerState extends State<SplashManager> {
  bool _showSplash = true;
  bool _userFetched = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _fetchUserAndStartSplash();
  }

  Future<void> _fetchUserAndStartSplash() async {
    try {
      final user = await AtStartService.fetchUserData();
      // Check if widget is still mounted before updating providers
      if (mounted) {
        // Update both UserCubit (Bloc pattern) and UserProvider (Provider pattern)
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }
    } on Exception catch (e) {
      e;
      // Continue with app initialization even if user fetch fails
    }

    // Wait for splash duration
    await Future.delayed(Dimensions.splashDuration);

    // Check if widget is still mounted before updating state
    if (mounted) {
      setState(() {
        _showSplash = false;
        _userFetched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash || !_userFetched) {
      return const SplashScreen();
    }

    return const AppNavigator();
  }
}
