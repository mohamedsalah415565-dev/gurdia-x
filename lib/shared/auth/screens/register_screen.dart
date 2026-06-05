import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/shared/auth/screens/add_profile_screen.dart';
import 'package:guardian_x/shared/auth/screens/login_screen.dart';
import 'package:guardian_x/shared/widgets/buttom_navigation_bar.dart';
import 'package:guardian_x/shared/widgets/google_login_button.dart';
import 'package:guardian_x/shared/widgets/register_form.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/RegisterScreen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------- EMAIL REGISTER SUCCESS ----------------
  void onRegisterSuccess() {
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AddProfileScreen.routeName,
      (_) => false,
    );
  }

  // ---------------- GOOGLE SIGN IN ----------------
  Future<void> _handleGoogleSignIn() async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      setState(() => isLoading = true);

      final user = await AuthService.signInWithGoogle();

      if (!mounted || user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      final bool setupComplete = data?['setup_complete'] ?? false;

      // 🔥 FINAL FLOW FIX
      if (setupComplete == false && (data?['name'] == "" || data == null)) {
        // NEW USER → REGISTER FLOW
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AddProfileScreen.routeName,
          (_) => false,
        );
      } else {
        // EXISTING USER → LOGIN FLOW
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          MainScreen.routeName,
          (_) => false,
        );
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Image.asset(
                'assets/images/login_image.png',
                height: screenHeight * 0.22,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),

              Text("Create Account", style: theme.textTheme.headlineMedium),

              const SizedBox(height: 10),

              // ---------------- REGISTER FORM ----------------
              RegisterForm(
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                formKey: formKey,
                onRegister: onRegisterSuccess,
              ),

              const SizedBox(height: 20),

              // ---------------- DIVIDER ----------------
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1.2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: theme.textTheme.bodyMedium),
                  ),
                  const Expanded(child: Divider(thickness: 1.2)),
                ],
              ),

              const SizedBox(height: 16),

              // ---------------- GOOGLE SIGN IN ----------------
              LoginGoogleButton(onTap: _handleGoogleSignIn),

              const SizedBox(height: 20),

              // ---------------- LOGIN LINK ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: AppTheme.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
