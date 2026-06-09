import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';

import './custom_elevated_button.dart';
import './custome_text_form_feild.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onRegister;

  const RegisterForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    this.onRegister,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> handleRegister() async {
    if (widget.formKey.currentState == null) return;

    if (!widget.formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthService.register(
        email: widget.emailController.text.trim(),
        password: widget.passwordController.text.trim(),
      );

      if (!mounted) return;

      widget.onRegister?.call();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.red),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// EMAIL
          const Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          CustomTextField(
            controller: widget.emailController,
            hint: "Email",
            prefixIcon: const Icon(Icons.email),

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }

              final email = value.trim();

              final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

              if (!emailRegex.hasMatch(email)) {
                return 'Enter a valid email address';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          /// PASSWORD
          const Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          CustomTextField(
            controller: widget.passwordController,
            hint: "Password",
            obscure: obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }

              if (value.length < 8) {
                return 'Minimum 8 characters';
              }

              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Add uppercase letter';
              }

              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return 'Add lowercase letter';
              }

              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Add number';
              }

              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return 'Add special character';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          /// CONFIRM PASSWORD
          const Text(
            "Confirm Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          CustomTextField(
            controller: widget.confirmPasswordController,
            hint: "Confirm Password",
            obscure: obscureConfirmPassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscureConfirmPassword = !obscureConfirmPassword;
                });
              },
            ),

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }

              if (value != widget.passwordController.text) {
                return 'Passwords do not match';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),

          /// REGISTER BUTTON
          CustomButton(
            text: "Register",
            onPressed: handleRegister,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
