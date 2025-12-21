import 'dart:convert';
import 'package:askcam/core/config/app_runtime_config.dart';
import 'package:askcam/core/config/cloudinary_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ImageUploadService {
  ImageUploadService._({
    FirebaseAuth? auth,
    http.Client? client,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  static final ImageUploadService instance = ImageUploadService._();

  final FirebaseAuth _auth;
  final http.Client _client;

  Future<String> uploadImage(
    Uint8List bytes, {
    required String fileName,
  }) async {
    if (!CloudinaryConfig.hasConfig) {
      AppRuntimeConfig.logMissingConfig();
      throw StateError('Cloudinary config missing');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }

    final mimeType = lookupMimeType(fileName, headerBytes: bytes) ??
        _detectMimeType(bytes);
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = 'askcam/$uid/gallery'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

    http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Cloudinary upload error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw StateError('No internet connection');
    }

    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (kDebugMode) {
        debugPrint('Cloudinary upload failed: ${response.statusCode} $body');
      }
      throw StateError('Upload failed');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final url = data['secure_url']?.toString();
    if (url == null || url.isEmpty) {
      throw StateError('Upload failed');
    }
    return url;
  }

  String _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg';
  }
}
