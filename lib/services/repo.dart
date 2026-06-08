import 'dart:io';
import 'package:guardian_x/services/cloudinary_services.dart';
import 'package:guardian_x/services/fire_store.dart';

class EventRepository {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> uploadAndSaveEvent(File file) async {
    try {
      // ignore: avoid_print
      print("🚀 Start uploading file...");

      // رفع الفيديو على Cloudinary
      final videoUrl = await _cloudinaryService.uploadFile(file, isVideo: true);

      // ignore: avoid_print
      print("📹 Video URL: $videoUrl");

      // لو الرفع فشل
      if (videoUrl == null || videoUrl.isEmpty) {
        // ignore: avoid_print
        print("❌ Upload failed - videoUrl is null or empty");
        return;
      }

      // ignore: avoid_print
      print("💾 Saving to Firestore...");

      // حفظ البيانات في Firestore
      await _firestoreService.saveEvent(
        videoUrl: videoUrl,
        type: "camera_event",
      );

      // ignore: avoid_print
      print("✅ Event saved successfully!");
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print("🔥 ERROR in uploadAndSaveEvent: $e");
      // ignore: avoid_print
      print("📍 StackTrace: $stackTrace");
    }
  }
}
