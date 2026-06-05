import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudinaryService {
  final String cloudName = "dqgnexaj5";
  final String uploadPreset = "gggggg";

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<String?> uploadFile(File file, {bool isVideo = false}) async {
    try {
      // ignore: avoid_print
      print("🚀 Starting upload to Cloudinary...");

      // تأكد إن الملف موجود
      if (!file.existsSync()) {
        throw Exception("❌ File does not exist");
      }

      final endpoint = isVideo ? "video" : "image";
      final url =
          "https://api.cloudinary.com/v1_1/$cloudName/$endpoint/upload";

      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? "unknown";

      // ignore: avoid_print
      print("👤 UID: $uid");
      // ignore: avoid_print
      print("📁 File path: ${file.path}");

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        "upload_preset": uploadPreset,
        "folder": "users/$uid",
      });

      final response = await _dio.post(url, data: formData);

      // ignore: avoid_print
      print("📡 Status Code: ${response.statusCode}");
      // ignore: avoid_print
      print("📦 Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final secureUrl = response.data["secure_url"];

        if (secureUrl != null && secureUrl.toString().isNotEmpty) {
          // ignore: avoid_print
          print("✅ Upload success: $secureUrl");
          return secureUrl;
        } else {
          throw Exception("❌ secure_url is null");
        }
      } else {
        throw Exception("❌ Upload failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // ignore: avoid_print
      print("🔥 Dio ERROR: ${e.message}");
      // ignore: avoid_print
      print("📦 Response Data: ${e.response?.data}");
      return null;
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print("🔥 ERROR: $e");
      // ignore: avoid_print
      print("📍 StackTrace: $stackTrace");
      return null;
    }
  }
}