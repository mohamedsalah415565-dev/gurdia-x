import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child("profile_images/$uid.jpg");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}
