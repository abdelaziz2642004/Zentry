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

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return BlocListener<AccountCubit, AccountStates>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
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
}
