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

  Future<AppUser?> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }
}
