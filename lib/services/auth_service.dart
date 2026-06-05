import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;

  // LOGIN
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user == null) throw "Login failed";
    return cred.user!;
  }

  // REGISTER
  static Future<User> register({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) throw "User creation failed";

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'name': "",
      'profile_image': "",
      'setup_complete': false,
      'created_at': FieldValue.serverTimestamp(),
      'role': 'user',
    });

    return user;
  }

  // GOOGLE SIGN IN
  static Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return null;

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? "",
        'name': user.displayName ?? "",
        'profile_image': user.photoURL ?? "",
        'setup_complete': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  static Future<void> finalizeProfile({
    required String uid,
    required String name,
    required String imageUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'profile_image': imageUrl,
      'setup_complete': true,
    }, SetOptions(merge: true));
  }

  // LOGOUT
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
