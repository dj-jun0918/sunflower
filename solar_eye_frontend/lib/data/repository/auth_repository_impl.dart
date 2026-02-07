import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:solar_eye_frontend/domain/repository/auth_repository.dart';

import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final Dio _dio;

  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn, this._dio);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<void> signInWithGoogle() async {
    print('Called signInWithGoogle from:\n${StackTrace.current}');
    try {
      if (kIsWeb) {
        // Web: Use signInWithPopup directly via FirebaseAuth
        // This avoids the need for manual Google Client ID configuration in index.html
        // and uses the Firebase project's authorized domains automatically.
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        final user = userCredential.user;

        if (user != null) {
          await _syncWithBackend(user);
        }
      } else {
        // Native (Android/iOS): Use GoogleSignIn plugin
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          // The user canceled the sign-in
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        print(
            '🔐 Google Auth Tokens: Access=${googleAuth.accessToken?.substring(0, 5)}..., ID=${googleAuth.idToken?.substring(0, 5)}...');

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          await _syncWithBackend(user);
        }
      }
    } catch (e) {
      // TODO: Handle exceptions
      print('Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<void> _syncWithBackend(User user) async {
    try {
      print('🔄 Syncing with backend for user: ${user.uid}');
      final idToken = await user.getIdToken();

      // Call endpoint to create or update user in Postgres
      await _dio.post(
        '/api/v1/auth/login',
        data: {
          'id_token': idToken,
        },
      );
      print('✅ Backend sync successful');
    } catch (e) {
      print('❌ Backend sync failed: $e');
      // We don't rethrow here to allow the user to continue using the app
      // even if backend sync fails (though some features might be limited)
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
