import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  final String id;
  final String url;
  final String fileName;
  final int size;
  final String source;
  final DateTime? createdAt;

  const GalleryItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.size,
    required this.source,
    required this.createdAt,
  });

  factory GalleryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final timestamp = data?['createdAt'] as Timestamp?;
    return GalleryItem(
      id: doc.id,
      url: data?['url']?.toString() ?? '',
      fileName: data?['fileName']?.toString() ?? '',
      size: (data?['size'] as num?)?.toInt() ?? 0,
      source: data?['source']?.toString() ?? 'camera',
      createdAt: timestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool includeServerTimestamp = true}) {
    return {
      'url': url,
      'fileName': fileName,
      'size': size,
      'source': source,
      if (includeServerTimestamp) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
