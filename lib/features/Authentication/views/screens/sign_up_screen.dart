import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/repositories/auth_repo.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20Up/sign_up_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(AuthRepo()),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/JSON/Welcome.json',
                      height: 200,
                      repeat: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: "DopisBold",
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SignupForm(),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83),
                              fontFamily: "DopisBold",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Sign in",
                            style: TextStyle(
                              color: mainColor,
                              fontFamily: "DopisBold",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<GuestmodeCubit>(
                          context,
                        ).enableGuestMode();
                      },
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
