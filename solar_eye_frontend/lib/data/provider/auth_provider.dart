import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/repository/auth_repository_impl.dart';
import 'package:solar_eye_frontend/domain/repository/auth_repository.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';

part 'auth_provider.g.dart';

// 1. Provider for FirebaseAuth instance
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  debugPrint('🔐 [1] Creating FirebaseAuth provider');
  return FirebaseAuth.instance;
}

// 2. Provider for GoogleSignIn instance (nullable for Web)
@riverpod
GoogleSignIn? googleSignIn(GoogleSignInRef ref) {
  debugPrint('🔐 [2] Creating GoogleSignIn provider');
  if (kIsWeb) {
    debugPrint('🌐 [2.1] Web detected, returning null for GoogleSignIn plugin');
    return null;
  }
  return GoogleSignIn();
}

// 3. Provider for our AuthRepository implementation
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  debugPrint('🔐 [3] Creating AuthRepository provider');
  final auth = ref.watch(firebaseAuthProvider);
  debugPrint('🔐 [3.1] Got FirebaseAuth');
  final google = ref.watch(googleSignInProvider);
  debugPrint(
      '🔐 [3.2] Got GoogleSignIn (${google == null ? 'null' : 'active'})');
  final dio = ref.watch(apiClientProvider);
  debugPrint('🔐 [3.3] Got Dio client');
  final repo = AuthRepositoryImpl(auth, google, dio);
  debugPrint('🔐 [3.4] Created AuthRepositoryImpl');
  return repo;
}

// 4. StreamProvider to listen to authentication state changes
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) async* {
  debugPrint('🔐 [4] Creating authStateChanges provider');
  final repo = ref.watch(authRepositoryProvider);
  debugPrint('🔐 [4.1] Got AuthRepository, returning stream with delay check');

  if (kIsWeb) {
    debugPrint(
        '⏳ Web platform detected - delaying auth stream subscription by 1500ms');
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // Wrap stream with error handling to capture the actual error
  yield* repo.authStateChanges.handleError((error, stackTrace) {
    debugPrint('🔐 [ERROR] Stream error: $error');
    debugPrint('🔐 [ERROR] Stack trace: $stackTrace');
  });
}
