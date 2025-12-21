import 'package:cloud_firestore/cloud_firestore.dart';

class SavedWord {
  final String id;
  final String text;
  final String normalized;
  final DateTime? createdAt;
  final String source;
  final String? imageId;
  final String? language;

  const SavedWord({
    required this.id,
    required this.text,
    required this.normalized,
    required this.createdAt,
    required this.source,
    this.imageId,
    this.language,
  });

  factory SavedWord.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data?['createdAt'] as Timestamp?;
    return SavedWord(
      id: doc.id,
      text: data?['text']?.toString() ?? '',
      normalized: data?['normalized']?.toString() ?? '',
      createdAt: timestamp?.toDate(),
      source: data?['source']?.toString() ?? 'ocr',
      imageId: data?['imageId']?.toString(),
      language: data?['language']?.toString(),
    );
  }

  Map<String, dynamic> toMap({bool includeServerTimestamp = true}) {
    return {
      'text': text,
      'normalized': normalized,
      'source': source,
      'imageId': imageId,
      'language': language,
      if (includeServerTimestamp) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
