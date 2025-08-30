import 'package:flutter/material.dart';

class LoadingUtils {
  /// Builds a small circular progress indicator for buttons
  static Widget buildButtonLoader({
    double size = 16.0,
    double strokeWidth = 2.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
      ),
    );
  }

  /// Builds a centered loading indicator with padding
  static Widget buildCenteredLoader({
    EdgeInsets padding = const EdgeInsets.all(16.0),
  }) {
    return Center(
      child: Padding(
        padding: padding,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  /// Determines button text based on various states
  static String getButtonText({
    required bool isCheckingRequest,
    required bool isAlreadyFriends,
    required bool hasExistingRequest,
    String defaultText = 'Send Request',
  }) {
    if (isCheckingRequest) {
      return 'Checking...';
    } else if (isAlreadyFriends) {
      return 'Already Friends';
    } else if (hasExistingRequest) {
      return 'Accept Request';
    } else {
      return defaultText;
    }
  }

  /// Determines button action based on various states
  static VoidCallback? getButtonAction({
    required bool isCheckingRequest,
    required bool isAlreadyFriends,
    required bool hasExistingRequest,
    required bool isDisabled,
    required VoidCallback? onAcceptRequest,
    required VoidCallback? onSendRequest,
  }) {
    if (isCheckingRequest || isAlreadyFriends || isDisabled) {
      return null;
    } else if (hasExistingRequest) {
      return onAcceptRequest;
    } else {
      return onSendRequest;
    }
  }

  /// Determines button color based on state
  static Color getButtonColor({
    required bool isAlreadyFriends,
    required bool hasExistingRequest,
    required Color defaultColor,
    Color? disabledColor,
  }) {
    if (isAlreadyFriends) {
      return disabledColor ?? Colors.grey;
    } else if (hasExistingRequest) {
      return Colors.green;
    } else {
      return defaultColor;
    }
  }
}
