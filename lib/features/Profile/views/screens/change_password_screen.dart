import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'package:zentry_pomodoro_app/core/dialogues.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_states.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String oldPassword = "";
  String newPassword = "";
  final _formKey = GlobalKey<FormState>();

  bool _isObscureOldPassword = true; // Flag to control old password visibility
  bool _isObscureNewPassword = true; // Flag to control new password visibility
  bool _isLoading = false; // Flag to track loading state

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Password'), elevation: 0),
        body: BlocConsumer<AccountCubit, AccountStates>(
          listener: (context, state) async {
            // Capture context before async operations
            final currentContext = context;

            if (state is AccountLoadingState) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            } else {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }

            if (state is PasswordError) {
              if (currentContext.mounted) {
                showErrorDialog(
                  'Error updating password: ${state.error}',
                  currentContext,
                );
              }
            } else if (state is SameOldPassword) {
              if (currentContext.mounted) {
                showErrorDialog(
                  'The new password must be different from the old password.',
                  currentContext,
                );
              }
            } else if (state is PasswordSuccess) {
              await Future.delayed(const Duration(seconds: 3), () {});

              if (currentContext.mounted) {
                Navigator.pop(currentContext);
              }
            }
          },
          builder: (context, state) {
            if (state is AccountLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PasswordSuccess) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/JSON/success.json',
                    repeat: false,
                    animate: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Password changed successfully!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 57, 204),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureOldPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureOldPassword = !_isObscureOldPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _isObscureOldPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        oldPassword = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureNewPassword = !_isObscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _isObscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (!RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$',
                        ).hasMatch(value)) {
                          return 'Password must be at least 6 characters long \n and include upper, lower, digit, and special characters';
                        }
                        newPassword = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          BlocProvider.of<AccountCubit>(
                            context,
                          ).changePassword(oldPassword, newPassword);
                        }
                      },
                      child: const Text('Update Password'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
