import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/screens/login_screen.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountStates>(
      listener: (context, state) {
        if (state is UserDeletionSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Loginscreen()),
            (route) => false,
          );
        } else if (state is UserDeletionError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.white,
          ),
          body: BlocBuilder<AccountCubit, AccountStates>(
            builder: (context, state) {
              if (state is AccountLoadingState) {
                // Show a loading indicator while the account is being deleted
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  if (FirebaseAuth.instance.currentUser != null) ...[
                    ListTile(
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.lock, color: mainColor),
                      onTap: () {
                        final accountCubit = BlocProvider.of<AccountCubit>(
                          context,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => BlocProvider.value(
                                  value: accountCubit,
                                  child: const ChangePasswordScreen(),
                                ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Delete Account'),
                      trailing: const Icon(Icons.delete, color: Colors.red),
                      onTap: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                'Are you sure you want to delete your account?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldDelete == true) {
                          await BlocProvider.of<AccountCubit>(
                            context,
                          ).deleteAccount();
                        }
                      },
                    ),
                    const Divider(),
                  ],
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Filters ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
