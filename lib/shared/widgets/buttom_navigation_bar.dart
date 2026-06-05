import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/home_screen.dart';
import 'package:guardian_x/shared/screens/camera_screen.dart';
import 'package:guardian_x/shared/screens/settings_screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String routeName = '/MainScreen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final items = [
    Icon(Icons.home, size: 24),
    Icon(Icons.camera_alt),
    Icon(Icons.settings),
  ];

  final screens = [
    const HomeScreen(),
    const CameraScreen(),
    const SettingsScreens(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: screens[currentIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(
            context,
          ).copyWith(iconTheme: IconThemeData(color: Colors.white)),
          child: CurvedNavigationBar(
            backgroundColor: Colors.transparent, // الخلفية خلف البار
            color: Colors.black, // لون البار نفسه
            buttonBackgroundColor:
                Colors.black, // لون الدائرة المرتفعة (يمكنك تغييره لتمييزها)
            height: 60, // زيادة الارتفاع قليلاً تعطي مساحة للدائرة لتبرز
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 300),
            index: currentIndex,
            items: [
              // لتكبير الدائرة، قم بتكبير حجم الأيقونة (Size)
              // أو وضع الأيقونة داخل Container مع Padding
              Icon(Icons.home, size: 35),
              Icon(Icons.camera_alt, size: 35),
              Icon(Icons.settings, size: 35),
            ],
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
// BottomNavigationBar(
//         currentIndex: currentIndex,
//         onTap: (index) {
//           setState(() {
//             currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.camera_alt),
//             label: "Camera",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Settings",
//           ),
//         ],
//       ),