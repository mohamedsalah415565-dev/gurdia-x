import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current device location
  Future<Position> getCurrentLocation() async {
    // 1. Check location service (GPS)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Please enable GPS (Location services).');
    }

    // 2. Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    // 3. Permanently denied
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception(
        'Permission permanently denied. Open settings to enable it.',
      );
    }

    // 4. Get position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Save event with location
  Future<void> saveEvent({
    required String videoUrl,
    required String type,
    String badge = 'mobile',
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final Position position = await getCurrentLocation();

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('mobile_reports')
        .add({
          'videoUrl': videoUrl,
          'type': type,
          'badge': badge,
          'email': user.email,
          'uid': user.uid,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location': GeoPoint(position.latitude, position.longitude),
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
}
