import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';

class FullNameField extends StatelessWidget {
  const FullNameField({super.key, required this.onChanged});
  final void Function(String) onChanged;
  //            onChanged: (value) => _fullName = value, // will be passed

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged, // will be passed
      validator: (val) {
        if (val == '') return AppConstants.fieldCannotBeEmpty;
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Full Name',
        labelStyle: const TextStyle(fontFamily: Fonts.dopisBold),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
        ),
        prefixIcon: const Icon(Icons.email, color: mainColor),
      ),
    );
  }
}
