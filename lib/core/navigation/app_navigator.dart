import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/services/atstart_service.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_states.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/screens/login_screen.dart';
import 'package:zentry_pomodoro_app/features/Home/views/screens/tabs.dart';

/// Handles navigation logic based on authentication and guest mode states
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _userDataFetchedForCurrentSession = false;
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestmodeCubit, GuestmodeStates>(
      builder: (context, guestModeState) {
        if (guestModeState is GuestModeEnabledState) {
          return const TabsScreen();
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              _handleAuthenticatedUser(snapshot.data!);
              return const TabsScreen();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              // return const Center(child: CircularProgressIndicator());
              return const Center();
            } else {
              _handleUnauthenticatedUser();
              return const Loginscreen();
            }
          },
        );
      },
    );
  }

  void _handleAuthenticatedUser(User firebaseUser) {
    final currentUserId = firebaseUser.uid;

    // Fetch user data only if user changed or not fetched yet
    if (_lastUserId != currentUserId || !_userDataFetchedForCurrentSession) {
      _lastUserId = currentUserId;
      _userDataFetchedForCurrentSession = true;
      _updateUserProvider(firebaseUser);
    }

    // Disable guest mode for authenticated users
    if (mounted) {
      BlocProvider.of<GuestmodeCubit>(context).disableGuestMode();
    }
  }

  void _handleUnauthenticatedUser() {
    // Clear user data and reset flags when user is not authenticated
    if (_lastUserId != null) {
      _lastUserId = null;
      _userDataFetchedForCurrentSession = false;

      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).clearUser();
        }
      });
    }
  }

  void _updateUserProvider(User firebaseUser) async {
    try {
      final user = await AtStartService.fetchUserData();
      // Check if widget is still mounted before updating providers
      if (mounted) {
        // Update both UserCubit (Bloc pattern) and UserProvider (Provider pattern)
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }
    } on Exception catch (e) {
      e;
      // If there's an error fetching user data, clear both providers
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }
    }
  }

  /// Method to force refresh user data when needed (e.g., after profile updates)
  void forceRefreshUserData() {
    _userDataFetchedForCurrentSession = false;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _updateUserProvider(currentUser);
    }
  }
}
