import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/constants/asset_paths.dart';

//restore?

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AssetPaths.logoAnimation,
              width: Dimensions.logoSize,
              height: Dimensions.logoSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: Dimensions.spacingMassive),
            Text(
              AppConstants.appName,
              style: GoogleFonts.breeSerif(
                fontSize: Dimensions.fontSizeMassive,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: Dimensions.spacingLarge),
            Text(
              AppConstants.appTagline,
              style: GoogleFonts.breeSerif(
                fontSize: Dimensions.fontSizeMedium,
                fontWeight: FontWeight.w200,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
