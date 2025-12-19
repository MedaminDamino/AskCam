import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? photoUrl;
  final String role;
  final bool isActive;

  const AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.createdAt,
    this.lastLoginAt,
    this.photoUrl,
    this.role = 'user',
    this.isActive = true,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      createdAt: _toDate(map['createdAt']),
      lastLoginAt: _toDate(map['lastLoginAt']),
      photoUrl: map['photoURL'] as String?,
      role: map['role'] as String? ?? 'user',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'photoURL': photoUrl,
      'role': role,
      'isActive': isActive,
    };
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
