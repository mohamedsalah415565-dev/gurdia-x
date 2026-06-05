import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/shared/auth/screens/add_profile_screen.dart';
import 'package:guardian_x/shared/widgets/buttom_navigation_bar.dart';
import 'package:guardian_x/shared/widgets/login_form.dart';
import 'package:guardian_x/shared/auth/screens/register_screen.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';
import 'package:guardian_x/shared/widgets/custom_elevated_button.dart';
import 'package:guardian_x/shared/widgets/google_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/LoginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
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

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Top Illustration
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Image.asset(
                  'assets/images/login_image.png',
                  height: screenHeight * 0.25,
                  fit: BoxFit.contain,
                ),
              ),

              // Login Form
              LoginForm(
                emailController: emailController,
                passwordController: passwordController,
                formKey: formKey,
              ),
              const SizedBox(height: 16),

              // Login Button
              CustomButton(
                text: 'Login',
                isLoading: _isLoading,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  setState(() => _isLoading = true);

                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  try {
                    await AuthService.login(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    if (!mounted) return;

                    navigator.pushNamedAndRemoveUntil(
                      MainScreen.routeName,
                      (_) => false,
                    );
                  } catch (e) {
                    if (!mounted) return;

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppTheme.red,
                      ),
                    );
                  }

                  if (mounted) setState(() => _isLoading = false);
                },
              ),

              const SizedBox(height: 22),

              // OR divider
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

              // Google Sign-In
              LoginGoogleButton(
                // Wrap async function in a synchronous closure
                onTap: () => _handleGoogleSignIn(),
              ),

              const SizedBox(height: 20),

              // Footer: Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Text(
                      'Register',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: AppTheme.red,
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
