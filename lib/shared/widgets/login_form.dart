import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';
import 'package:guardian_x/shared/widgets/custome_text_form_feild.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true;

  /// EMAIL VALIDATOR
  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// PASSWORD VALIDATOR
  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// FORGOT PASSWORD
  Future<void> _forgotPassword() async {
    final email = widget.emailController.text.trim();

    if (_emailValidator(email) != null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email address first")),
      );
      return;
    }

    final scaffold = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      scaffold.showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;

        case 'invalid-email':
          message = 'Invalid email address';
          break;

        case 'too-many-requests':
          message = 'Too many requests. Try again later';
          break;

        default:
          message = e.message ?? 'Failed to send reset email';
      }

      scaffold.showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      scaffold.showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// EMAIL
          Text("Email", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),

          CustomTextField(
            controller: widget.emailController,
            hint: "Enter your email",
            prefixIcon: const Icon(Icons.email_outlined, size: 26),
            validator: _emailValidator,
          ),

          const SizedBox(height: 20),

          /// PASSWORD
          Text("Password", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),

          CustomTextField(
            controller: widget.passwordController,
            hint: "Enter your password",
            obscure: obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline, size: 26),
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
            validator: _passwordValidator,
          ),

          const SizedBox(height: 16),

          /// FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: Text(
                "Forgot Password?",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
