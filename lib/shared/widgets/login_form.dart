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

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Email label
          Text("Email", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),

          /// Email input
          CustomTextField(
            controller: widget.emailController,
            hint: "Enter your email",
            prefixIcon: const Icon(Icons.email_outlined, size: 26),
            validator: (value) => (value == null || !value.contains('@'))
                ? "Enter a valid email"
                : null,
          ),
          const SizedBox(height: 20),

          /// Password label
          Text("Password", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),

          /// Password input with toggle
          CustomTextField(
            controller: widget.passwordController,
            hint: "Enter your password",
            obscure: obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline, size: 26),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
            ),
            validator: (value) => (value == null || value.length < 6)
                ? "Password too short"
                : null,
          ),
          SizedBox(height: 16),

          /// Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final email = widget.emailController.text.trim();
                if (email.isEmpty) {
                  if (!mounted) return; // Guard State usage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter your email first")),
                  );
                  return;
                }

                // Capture scaffold context before async gap
                final scaffold = ScaffoldMessenger.of(context);

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );

                  if (!mounted) return; // Guard after async
                  scaffold.showSnackBar(
                    const SnackBar(content: Text("Password reset email sent")),
                  );
                } catch (e) {
                  if (!mounted) return; // Guard after async
                  scaffold.showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
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
