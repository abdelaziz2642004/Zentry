import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/constants/asset_paths.dart';

void showErrorDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text(AppConstants.operationFailed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                AssetPaths.failedAnimation,
                height: Dimensions.lottieSmallHeight,
                width: Dimensions.lottieSmallWidth,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: Dimensions.paddingMedium),
              // Text(message),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(AppConstants.okayText),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
  );
}
