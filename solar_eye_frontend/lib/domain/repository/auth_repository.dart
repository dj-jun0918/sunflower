import 'package:firebase_auth/firebase_auth.dart';

/// An abstract class representing the authentication repository.
/// This defines the contract for authentication-related operations.
abstract class AuthRepository {
  /// Signs in the user with Google.
  ///
  /// Returns a [Future] that completes with a [User] object on success,
  /// or throws an exception on failure.
  Future<void> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();

  /// A stream of the current user's authentication state.
  /// Emits the user object when the user signs in, and null when they sign out.
  Stream<User?> get authStateChanges;
}
