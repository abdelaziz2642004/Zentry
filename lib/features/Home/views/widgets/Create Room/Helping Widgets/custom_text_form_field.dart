import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.textAlign,
  });

  final TextEditingController controller;
  final Function validator;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) => validator(value),
      decoration: const InputDecoration(border: InputBorder.none),
      keyboardType: keyboardType,
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}
