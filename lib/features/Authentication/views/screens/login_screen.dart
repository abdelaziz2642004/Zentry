import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/screens/sign_up_screen.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20In/login_form.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';
import 'package:zentry_pomodoro_app/core/constants/asset_paths.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/repositories/auth_repo.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(AuthRepo()),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingMedium),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      AssetPaths.welcomeAnimation,
                      height: Dimensions.lottieHeight,
                      repeat: true,
                    ),
                    const SizedBox(height: Dimensions.spacingMassive),
                    const Text(
                      AppConstants.welcomeBackText,
                      style: TextStyle(
                        fontSize: Dimensions.fontSizeHuge,
                        fontWeight: FontWeight.bold,
                        fontFamily: Fonts.dopisBold,
                      ),
                    ),
                    const SizedBox(height: Dimensions.spacingMassive),
                    const LoginForm(), // Made LoginForm const

                    TextButton(
                      onPressed:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const SignupScreen(),
                            ), // Added const
                          ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.dontHaveAccountText,
                            style: TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83),
                              fontFamily: Fonts.dopisBold,
                            ),
                          ),
                          Text(
                            AppConstants.signUpText,
                            style: TextStyle(
                              color: mainColor,
                              fontFamily: Fonts.dopisBold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
