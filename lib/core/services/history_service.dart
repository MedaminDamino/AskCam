import 'package:askcam/core/models/history_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  HistoryService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static final HistoryService instance = HistoryService._();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _historyRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('history');
  }

  Future<void> saveExtractionToHistory({
    required String extractedText,
    required String source,
    String? imageId,
    String? imageUrl,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    await _historyRef(uid).add({
      'extractedText': extractedText,
      'source': source,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<HistoryItem>> watchHistory() {
    final uid = _uid;
    if (uid == null) return Stream.value(<HistoryItem>[]);
    return _historyRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => HistoryItem.fromDoc(doc)).toList(),
        );
  }

  Future<void> deleteHistoryItem(String id) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    await _historyRef(uid).doc(id).delete();
  }
}
