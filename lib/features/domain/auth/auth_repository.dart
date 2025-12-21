import 'package:firebase_auth/firebase_auth.dart';
import 'package:askcam/features/domain/auth/app_user.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<UserCredential?> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword({required String email});

  Future<void> updateLastLogin(String uid);

  Future<AppUser?> getUserProfile(String uid);
}
