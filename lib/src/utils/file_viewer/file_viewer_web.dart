import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class FileViewer {
  static Future<void> open(String url) async {
    try {
      web.window.open(url, '_blank');
    } catch (e) {
      debugPrint("Open file error: $e");
    }
  }

  static Future<void> downloadAndOpen(String url, String fileName) async {
    try {
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      anchor.click();
    } catch (e) {
      debugPrint("Download error: $e");
    }
  }

  static Future<void> saveAndOpen(
      List<int> bytes, String fileName, String mimeType) async {
    try {
      final Uint8List uint8list = Uint8List.fromList(bytes);
      final blob =
          web.Blob([uint8list.toJS].toJS, web.BlobPropertyBag(type: mimeType));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      anchor.click();

      // Cleanup
      Future.delayed(const Duration(seconds: 1), () {
        web.URL.revokeObjectURL(url);
      });
    } catch (e) {
      debugPrint("Download error: $e");
    }
  }
}
