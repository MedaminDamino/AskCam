import 'package:askcam/features/gallery/domain/gallery_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GalleryRepository {
  GalleryRepository._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static final GalleryRepository instance = GalleryRepository._();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _galleryRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('gallery');
  }

  Future<String> addImage({
    required String url,
    required String fileName,
    required int size,
    required String source,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    final docRef = _galleryRef(uid).doc();
    await docRef.set({
      'url': url,
      'fileName': fileName,
      'size': size,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<List<GalleryItem>> watchImages() {
    final uid = _uid;
    if (uid == null) return Stream.value(<GalleryItem>[]);
    return _galleryRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => GalleryItem.fromDoc(doc)).toList(),
        );
  }

  Future<void> deleteImage(String docId) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    await _galleryRef(uid).doc(docId).delete();
  }

  Future<void> updateImageText({
    required String docId,
    required String extractedText,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    final preview = extractedText.length <= 140
        ? extractedText
        : '${extractedText.substring(0, 140)}...';
    await _galleryRef(uid).doc(docId).update({
      'extractedTextPreview': preview,
      'extractedTextFull': extractedText,
    });
  }
}
