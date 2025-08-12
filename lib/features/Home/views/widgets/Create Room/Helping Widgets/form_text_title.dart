import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class FormTextTitle extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Color color;
  final Color shadow;
  final double fontSize;

  const FormTextTitle({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w600,
    this.color = white,
    this.shadow = darkMainColor,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: color,
          shadows: [
            Shadow(color: shadow, blurRadius: 3, offset: const Offset(1, 2)),
          ],
        ),
      ),
    );
  }
}
