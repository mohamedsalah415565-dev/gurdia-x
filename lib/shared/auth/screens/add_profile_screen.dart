import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/services/storage_service.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';
import 'package:guardian_x/shared/widgets/buttom_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';

class AddProfileScreen extends StatefulWidget {
  static const routeName = "/addProfile";
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  File? selectedImage;
  bool isLoading = false;

  final List<String> defaultImages = [
    "assets/images/Oval.png",
    "assets/images/default_2_man.png",
    "assets/images/default_3_woman.png",
  ];
  int selectedIndex = 0;

  /// Pick image from gallery
  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (file != null) {
      setState(() {
        selectedImage = File(file.path);
        selectedIndex = -1;
      });
    }
  }

  /// Finish profile setup
  Future<void> handleFinish() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      String imageUrl = "";

      if (selectedImage != null) {
        imageUrl = await StorageService.uploadProfileImage(
          uid: user.uid,
          file: selectedImage!,
        );
      } else {
        imageUrl = defaultImages[selectedIndex];
      }

      await AuthService.finalizeProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainScreen.routeName,
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true, // Keyboard resize
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            reverse: true, // Scroll when keyboard appears
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),

                  /// Title
                  Text("Add your profile", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 30),

                  /// Profile preview
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : AssetImage(defaultImages[selectedIndex])
                              as ImageProvider,
                  ),
                  const SizedBox(height: 10),

                  /// Name preview
                  Text(
                    _nameController.text.isEmpty
                        ? "Your Name"
                        : _nameController.text,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  /// Name input
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      filled: theme.inputDecorationTheme.filled,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      contentPadding: theme.inputDecorationTheme.contentPadding,
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder,
                      errorBorder: theme.inputDecorationTheme.errorBorder,
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 25),

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
                              radius: 28,
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

                  const SizedBox(height: 40),

                  /// Done button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleFinish,
                      style: theme.elevatedButtonTheme.style,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.white,
                            )
                          : Text("Done", style: theme.textTheme.titleMedium),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
