import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveEvent({
    required String videoUrl,
    required String type,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("❌ User not logged in");
    }

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("mobile_app")
        .add({
      "videoUrl": videoUrl,
      "type": type,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}