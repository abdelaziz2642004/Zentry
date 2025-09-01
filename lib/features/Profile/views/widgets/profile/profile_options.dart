// done
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/settings_screen.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_list_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/discovery_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/my_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/group_chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/streaks_achievements_screen.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return BlocListener<AccountCubit, AccountStates>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          // Clear all cubit states when logout is successful
          _clearAllCubitStates(context);

          // The AppNavigator will automatically handle navigation to login screen
          // when Firebase Auth state changes, so we don't need to navigate manually
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is LogoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Streaks & Achievements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Fonts.dopisBold,
              ),
            ),
            subtitle: const Text('View your progress and achievements'),
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StreaksAndAchievementsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              AppConstants.settingsAndPreferences,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Fonts.dopisBold,
              ),
            ),
            subtitle: const Text(AppConstants.manageAccountSettings),
            leading: const Icon(Icons.settings, color: mainColor),
            onTap: () {
              final accountCubit = BlocProvider.of<AccountCubit>(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider.value(
                        value: accountCubit,
                        child: const SettingsScreen(),
                      ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              user != null ? 'Sign Out' : 'Sign In',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Fonts.dopisBold,
                color: user != null ? Colors.red : Colors.green,
              ),
            ),
            subtitle:
                user != null
                    ? const Text('Sign out of your account')
                    : const Text('Sign in to your account'),
            leading:
                user != null
                    ? const Icon(Icons.logout, color: Colors.red)
                    : const Icon(Icons.login, color: Colors.green),
            onTap: () {
              if (user == null) {
                BlocProvider.of<GuestmodeCubit>(context).disableGuestMode();
                Navigator.pop(context);
                return;
              }
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  BlocProvider.of<AccountCubit>(context).logout();
                  // we should also clear the user provider
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  /// Clear all cubit states to prevent data persistence between users
  void _clearAllCubitStates(BuildContext context) {
    try {
      // Clear Friends cubits
      BlocProvider.of<FriendsCubit>(context).reset();
      BlocProvider.of<FriendsListCubit>(context).reset();
      BlocProvider.of<FriendRequestsCubit>(context).reset();

      // Clear Groups cubits
      BlocProvider.of<GroupsCubit>(context).reset();
      BlocProvider.of<DiscoveryGroupsCubit>(context).reset();
      BlocProvider.of<MyGroupsCubit>(context).reset();
      BlocProvider.of<GroupChatCubit>(context).reset();

      // Clear Chat cubit
      BlocProvider.of<ChatCubit>(context).reset();

      print('All cubit states cleared successfully');
    } catch (e) {
      print('Error clearing cubit states: $e');
    }
  }
}
