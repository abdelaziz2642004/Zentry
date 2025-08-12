import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class CustomPasswordField extends StatelessWidget {
  final String? errorText;

  const CustomPasswordField({
    super.key,
    this.errorText,
    required this.onChanged,
    required this.obsecurePassword,
    required this.onPressed,
    required this.validator,
    required this.labelText,
  });
  final void Function(String) onChanged;
  final bool obsecurePassword;

  final void Function() onPressed;

  final String? Function(String?) validator;

  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged, // will be passed
      obscureText: obsecurePassword, // will be passed
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontFamily: "DopisBold"),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        prefixIcon: const Icon(Icons.lock, color: mainColor),
        suffixIcon: IconButton(
          icon: Icon(
            obsecurePassword ? Icons.visibility : Icons.visibility_off,
            color: mainColor,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
