import 'package:askcam/core/models/saved_word.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedWordsService {
  SavedWordsService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static final SavedWordsService instance = SavedWordsService._();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _savedWordsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('saved_words');
  }

  Future<void> saveWord({
    required String text,
    String? imageId,
    String? language,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }

    final trimmed = text.trim();
    final normalized = _normalize(trimmed);
    final doc = SavedWord(
      id: '',
      text: trimmed,
      normalized: normalized,
      createdAt: null,
      source: 'ocr',
      imageId: imageId,
      language: language,
    );

    await _savedWordsRef(uid).add(doc.toMap());
  }

  Stream<List<SavedWord>> watchSavedWords() {
    final uid = _uid;
    if (uid == null) {
      return Stream.value(<SavedWord>[]);
    }

    return _savedWordsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedWord.fromDoc(doc))
              .toList(),
        );
  }

  Future<void> deleteWord(String id) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    await _savedWordsRef(uid).doc(id).delete();
  }

  Future<bool> existsNormalized(String normalized) async {
    final uid = _uid;
    if (uid == null) {
      return false;
    }
    final snapshot = await _savedWordsRef(uid)
        .where('normalized', isEqualTo: normalized)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  static String normalizeInput(String input) {
    return _normalize(input);
  }

  static String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
