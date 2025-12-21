import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:askcam/features/domain/auth/app_user.dart';

class UserProfileService {
  final FirebaseFirestore _firestore;

  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUserProfile(AppUser user) {
    return _users.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'photoURL': user.photoUrl,
      'role': user.role,
      'isActive': user.isActive,
    });
  }

  Future<void> updateLastLogin(String uid) {
    return _users.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureGoogleUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    final docRef = _users.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = <String, dynamic>{
        'uid': uid,
        'email': email,
        'displayName': displayName ?? '',
        'photoURL': photoUrl,
        'provider': 'google',
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

      if (!snapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(docRef, data, SetOptions(merge: true));
    });
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }
}
