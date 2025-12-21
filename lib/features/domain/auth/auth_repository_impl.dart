import 'package:firebase_auth/firebase_auth.dart';
import 'package:askcam/features/data/auth/auth_service.dart';
import 'package:askcam/features/data/auth/user_profile_service.dart';
import 'package:askcam/features/domain/auth/app_user.dart';
import 'package:askcam/features/domain/auth/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final UserProfileService _userProfileService;

  AuthRepositoryImpl({
    required AuthService authService,
    required UserProfileService userProfileService,
  })  : _authService = authService,
        _userProfileService = userProfileService;

  @override
  Stream<User?> authStateChanges() => _authService.authStateChanges();

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authService.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final credential = await _authService.signUp(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return;

    final appUser = AppUser(
      uid: user.uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photoUrl: user.photoURL,
      role: 'user',
      isActive: true,
    );

    await _userProfileService.createUserProfile(appUser);
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    final user = credential?.user;
    if (user == null) return credential;

    try {
      await _userProfileService.ensureGoogleUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } catch (e, stackTrace) {
      debugPrint('Profile sync failed after Google sign-in: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
    return credential;
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> resetPassword({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateLastLogin(String uid) {
    return _userProfileService.updateLastLogin(uid);
  }

  @override
  Future<AppUser?> getUserProfile(String uid) {
    return _userProfileService.getUserProfile(uid);
  }
}
