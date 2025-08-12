import 'package:flutter/material.dart';

class Dimensions {
  Dimensions._();

  // Padding and Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingExtraLarge = 24.0;
  static const double paddingHuge = 25.0;

  // Spacing
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;
  static const double spacingLarge = 10.0;
  static const double spacingExtraLarge = 12.0;
  static const double spacingHuge = 15.0;
  static const double spacingMassive = 20.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 20.0;
  static const double fontSizeHuge = 28.0;
  static const double fontSizeMassive = 30.0;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 5);
  static const Duration shortDelay = Duration(seconds: 3);
  static const Duration mediumDelay = Duration(seconds: 4);
  static const Duration timerInterval = Duration(seconds: 1);

  // Button Dimensions
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 40,
    vertical: 15,
  );

  // Container Dimensions
  static const double logoSize = 200.0;
  static const double lottieHeight = 200.0;
  static const double lottieWidth = 200.0;
  static const double lottieSmallHeight = 100.0;
  static const double lottieSmallWidth = 100.0;

  // Form Limits
  static const int maxSessions = 15;
  static const int maxWorkDuration = 180;
  static const int maxBreakDuration = 60;
  static const int maxRoomCapacity = 50;
  static const int minRoomCapacity = 1;
  static const int defaultSessions = 4;
  static const int defaultCapacity = 25;
  static const int defaultWorkDuration = 50;
  static const int defaultBreakDuration = 10;
}
