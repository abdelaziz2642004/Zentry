import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/screens/forgot_password_screen.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20In/email_field.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20In/password_field.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20In/sign_in_button.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_cubit.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/auth_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // final LoginService _loginService = LoginService();

  // @override
  // void initState() {
  //   super.initState();
  //   BlocProvider.of<AuthCubit>(context).authRepo.loginService = _loginService;
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        } else if (state is AuthSuccessState) {
          // UserProvider will be updated automatically by main.dart when Firebase Auth state changes
          // No need to manually update it here
          // The streambulder in main.dart will handle the navigation
          //:DDD TRADEMARK !! :D
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            EmailorUsernameField(
              onChanged: (value) => _emailController.text = value,
            ),
            const SizedBox(height: 20),
            PasswordField(
              obscurePassword: _obscurePassword,
              onChanged: (value) => _passwordController.text = value,
              toggleVisibility:
                  () => setState(() => _obscurePassword = !_obscurePassword),
              labelText: "Password",
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ForgotPasswordScreen(),
                        ),
                      ),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: mainColor, fontFamily: "DopisBold"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SignButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await BlocProvider.of<AuthCubit>(
                    context,
                  ).login(_emailController.text, _passwordController.text);
                }
              },
              type: "In",
            ),
          ],
        ),
      ),
    );
  }
}
