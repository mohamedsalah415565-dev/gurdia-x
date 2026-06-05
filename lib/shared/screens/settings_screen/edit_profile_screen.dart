import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final List<String> defaultImages = const [
    "assets/images/Oval.png",
    "assets/images/default_2_man.png",
    "assets/images/default_3_woman.png",
  ];

  int selectedIndex = 0; // الصورة الافتراضية من defaultImages
  File? selectedImage; // الصورة المختارة من الجهاز

  final ImagePicker _picker = ImagePicker();

  /// فتح معرض الصور لاختيار صورة
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        selectedIndex = -1; // يعني ما فيش default مختارة
      });
    }
  }

  /// حفظ الصورة في Firebase Storage وتحديث Firestore
  Future<void> saveProfileImage() async {
    String? imageUrl;

    if (selectedImage != null) {
      final uid = AuthService.currentUser?.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      await storageRef.putFile(selectedImage!);
      imageUrl = await storageRef.getDownloadURL();
    } else if (selectedIndex >= 0) {
      imageUrl = defaultImages[selectedIndex];
    }

    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser?.uid)
          .update({'profile_image': imageUrl});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),

                /// Title
                Text(
                  "Create a New Profile",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                /// Profile preview
                CircleAvatar(
                  radius: 88,
                  backgroundColor: AppTheme.white,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : AssetImage(defaultImages[selectedIndex])
                            as ImageProvider,
                ),
                const SizedBox(height: 120),

                /// Avatar selection row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      defaultImages.length,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            selectedImage = null;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedIndex == index
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: AppTheme.white,
                            backgroundImage: AssetImage(defaultImages[index]),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: pickImage,
                      icon: Icon(
                        Icons.add_a_photo,
                        size: 35,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 95),

                /// Done button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await saveProfileImage();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile updated successfully"),
                          ),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context); // ترجع للصفحة السابقة
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    style: theme.elevatedButtonTheme.style,
                    child: Text("Save", style: theme.textTheme.titleMedium),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}