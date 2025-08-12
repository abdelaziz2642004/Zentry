import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_container.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget content;
  final Color bgColor;
  final double? width;
  final double? height;
  final double? hPadding;
  final double? vPadding;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.content,
    required this.bgColor,
    this.width,
    this.height,
    this.hPadding,
    this.vPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        color: bgColor,
        width: width,
        vPadding: vPadding ?? 2,
        hPadding: hPadding ?? 4,
        child: content,
      ),
    );
  }
}
