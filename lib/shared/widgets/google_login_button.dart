import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Google login button used in Login screen
class LoginGoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const LoginGoogleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/icons/google_login.svg", height: 22),
            const SizedBox(width: 10),
            const Text("Continue with Google", style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
