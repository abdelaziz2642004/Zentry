import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';

class SignButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String type;

  const SignButton({required this.onPressed, required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final bool isLoading = state is AuthLoadingState;

        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: Dimensions.buttonPadding,
            backgroundColor: mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Dimensions.borderRadiusMedium,
              ),
            ),
          ),
          child:
              isLoading
                  ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : Text(
                    'Sign $type',
                    style: const TextStyle(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Colors.white,
                      fontFamily: Fonts.dopisBold,
                    ),
                  ),
        );
      },
    );
  }
}
