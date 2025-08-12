import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';
import 'package:zentry_pomodoro_app/core/functions.dart';

class EditableNameRow extends StatelessWidget {
  final String fullName;
  final VoidCallback onEdit;

  const EditableNameRow({
    super.key,
    required this.fullName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            capitalizeFirstLetterOfEachWord(fullName),
            style: const TextStyle(
              fontSize: Dimensions.fontSizeExtraLarge,
              fontWeight: FontWeight.bold,
              fontFamily: Fonts.dopisBold,
            ),
          ),
          const SizedBox(width: Dimensions.spacingExtraLarge),
          const Icon(
            Icons.edit,
            size: Dimensions.iconSizeSmall,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
