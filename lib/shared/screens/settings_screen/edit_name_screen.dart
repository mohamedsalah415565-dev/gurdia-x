import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _nameController = TextEditingController();

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
      appBar: AppBar(
        title: const Text("Edit Name"),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(AuthService.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("No profile found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// Title
                  Align(
                    alignment: Alignment.center,
                    child: const Text(
                      "Enter your new name",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: AppTheme.white,
                      backgroundImage: AssetImage(
                        'assets/images/edit_name.png',
                      ),
                    ),
                  ),

                  /// Name preview
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      data['name'],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 88),

                  /// Name input
                  TextField(
                    controller: _nameController,
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
                  const SizedBox(height: 88),

                  /// Save button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = _nameController.text.trim();
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Name cannot be empty"),
                            ),
                          );
                          return;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(AuthService.currentUser?.uid)
                              .update({'name': newName});

                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Name updated successfully"),
                            ),
                          );

                          // ارجع للصفحة السابقة بعد التحديث
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error updating name: $e")),
                          );
                        }
                      },
                      style: theme.elevatedButtonTheme.style,
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
