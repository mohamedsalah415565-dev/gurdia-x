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

  Future<void> handleRegister() async {
    // SAFETY: check form exists before validating
    if (widget.formKey.currentState == null) return;

    // Validate form
    if (!widget.formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthService.register(
        email: widget.emailController.text.trim(),
        password: widget.passwordController.text.trim(),
      );

      if (!mounted) return;

      // IMPORTANT: Call navigation callback only if registration succeeds
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

            // Improved email validation
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Enter email";
              }

              if (!v.contains("@")) {
                return "Enter valid email";
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
            obscure: true,
            prefixIcon: const Icon(Icons.lock),

            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Enter password";
              }

              if (v.length < 6) {
                return "Min 6 characters";
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
            obscure: true,
            prefixIcon: const Icon(Icons.lock_outline),

            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Confirm your password";
              }

              if (v != widget.passwordController.text) {
                return "Passwords don't match";
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
