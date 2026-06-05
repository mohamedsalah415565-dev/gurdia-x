import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/shared/auth/screens/login_screen.dart';
import 'package:guardian_x/shared/widgets/buttom_navigation_bar.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // لسه بيحمّل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // مسجّل دخول → MainScreen
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // مش مسجّل → LoginScreen
        return const LoginScreen();
      },
    );
  }
}