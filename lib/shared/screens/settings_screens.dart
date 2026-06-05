import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/shared/auth/screens/login_screen.dart';
import 'package:guardian_x/shared/screens/settings_screen/edit_name_screen.dart';
import 'package:guardian_x/shared/screens/settings_screen/edit_profile_screen.dart';

class SettingsScreens extends StatelessWidget {
  const SettingsScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings Screen",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService.logout();
                // Navigate back to login and remove all previous routes
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (route) => false,
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              child: Image.asset('assets/images/profile tab.png'),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditNameScreen()),
                );
              },
              child: Image.asset('assets/images/name tab.png'),
            ),
          ],
        ),
      ),
    );
  }
}
