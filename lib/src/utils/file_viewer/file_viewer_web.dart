import 'dart:convert';
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
    final base64 = base64Encode(bytes);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = 'data:$mimeType;base64,$base64';
    anchor.download = fileName;
    anchor.click();
  }
}
