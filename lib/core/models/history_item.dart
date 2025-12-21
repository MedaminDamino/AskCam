import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String extractedText;
  final String source;
  final String? imageUrl;
  final String? imageId;
  final DateTime? createdAt;

  const HistoryItem({
    required this.id,
    required this.extractedText,
    required this.source,
    required this.createdAt,
    this.imageUrl,
    this.imageId,
  });

  factory HistoryItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data?['createdAt'] as Timestamp?;
    return HistoryItem(
      id: doc.id,
      extractedText: data?['extractedText']?.toString() ?? '',
      source: data?['source']?.toString() ?? 'camera',
      imageUrl: data?['imageUrl']?.toString(),
      imageId: data?['imageId']?.toString(),
      createdAt: timestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool includeServerTimestamp = true}) {
    return {
      'extractedText': extractedText,
      'source': source,
      'imageUrl': imageUrl,
      'imageId': imageId,
      if (includeServerTimestamp) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
