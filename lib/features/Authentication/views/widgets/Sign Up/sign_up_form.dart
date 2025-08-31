import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20In/sign_in_button.dart';

import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_states.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/services/sign_up_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20Up/image_picker.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20Up/custom_password_field.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20Up/full_name_field.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  File? _selectedImage;
  String? _emailError;
  String? _usernameError;

  // final SignupService _signupService = SignupService();

  // @override
  // void initState() {
  //   super.initState();
  //   BlocProvider.of<AuthCubit>(context).authRepo.signupService = _signupService;
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailAvailability(String email) async {
    if (email.isEmpty) {
      setState(() => _emailError = null);
      return;
    }

    final isAvailable = await SignupService.isEmailAvailable(email);
    setState(() {
      _emailError = isAvailable ? null : 'Email already exists';
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() => _usernameError = null);
      return;
    }

    final isAvailable = await SignupService.isUsernameAvailable(username);
    setState(() {
      _usernameError = isAvailable ? null : 'Username already exists';
    });
  }

  @override
  Widget build(BuildContext context) {
    const String pattern =
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$';
    final RegExp passRegex = RegExp(pattern);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 20),
                    Text(
                      'Account created successfully! Please verify your email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to login
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            UserImagePicker(
              onPickImage: (File img) => _selectedImage = img,
              fromProfile: false,
            ),

            TextFormField(
              controller: _emailController,
              onChanged: _checkEmailAvailability,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email cannot be empty';
                }
                if (!RegExp(
                  r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
                ).hasMatch(value)) {
                  return 'Enter a valid email';
                }
                if (_emailError != null) {
                  return _emailError;
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(fontFamily: "DopisBold"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.email, color: mainColor),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _usernameController,
              onChanged: _checkUsernameAvailability,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username cannot be empty';
                }
                if (value.length < 4) {
                  return 'Username must be 4 or more characters';
                }
                if (_usernameError != null) {
                  return _usernameError;
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(fontFamily: "DopisBold"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.person, color: mainColor),
              ),
            ),
            const SizedBox(height: 20),

            CustomPasswordField(
              labelText: "Password",
              onChanged: (value) => _passwordController.text = value,
              obsecurePassword: _obscurePassword1,
              onPressed:
                  () => setState(() => _obscurePassword1 = !_obscurePassword1),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password cannot be empty';
                }
                if (value.length < 6 || !passRegex.hasMatch(value)) {
                  return 'Password must be at least 6 characters \nand it must contain \nuppercase, lowercase \nnumber, and special character';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            CustomPasswordField(
              labelText: "Confirm Password",
              onChanged: (value) => _confirmPasswordController.text = value,
              obsecurePassword: _obscurePassword2,
              onPressed:
                  () => setState(() => _obscurePassword2 = !_obscurePassword2),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm password cannot be empty';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                if (!passRegex.hasMatch(value)) {
                  return 'Incorrect format.';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            FullNameField(
              onChanged: (value) => _fullNameController.text = value,
            ),
            const SizedBox(height: 20),

            SignButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Validate form data using service
                  final validationError = SignupService.validateSignupForm(
                    email: _emailController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    confirmPassword: _confirmPasswordController.text,
                    fullName: _fullNameController.text,
                  );

                  if (validationError != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(validationError)));
                    return;
                  }

                  // Call signup through cubit
                  await BlocProvider.of<AuthCubit>(context).signUp(
                    email: _emailController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    fullName: _fullNameController.text,
                    profileImage: _selectedImage,
                  );
                }
              },
              type: "Up",
            ),
          ],
        ),
      ),
    );
  }
}
