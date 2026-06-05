import 'package:flutter/material.dart';
import 'package:guardian_x/auth_gate.dart';
import 'package:guardian_x/shared/auth/screens/register_screen.dart';
import 'package:guardian_x/shared/auth/screens/add_profile_screen.dart';
import 'package:guardian_x/shared/on_boarding/onboarding_screen.dart';
import 'package:guardian_x/shared/widgets/buttom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';
import 'package:guardian_x/shared/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // ✅ نعرض Onboarding لأول مرة، وبعدين AuthGate يتولى الباقي
      home: onboardingCompleted ? const AuthGate() : const OnBording(),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        AddProfileScreen.routeName: (context) => AddProfileScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
      },
    );
  }
}