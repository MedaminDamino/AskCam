import 'dart:typed_data';

import 'image_bytes_loader_stub.dart'
    if (dart.library.io) 'image_bytes_loader_io.dart'
    if (dart.library.html) 'image_bytes_loader_web.dart';

Future<Uint8List?> loadImageBytes(String path) => loadImageBytesImpl(path);
