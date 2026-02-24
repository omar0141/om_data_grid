import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class FileViewer {
  static Future<void> open(String url) async {
    try {
      html.window.open(url, '_blank');
    } catch (e) {
      debugPrint("Open file error: $e");
    }
  }

  static Future<void> downloadAndOpen(String url, String fileName) async {
    try {
      html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
    } catch (e) {
      debugPrint("Download error: $e");
    }
  }

  static Future<void> saveAndOpen(
      List<int> bytes, String fileName, String mimeType) async {
    final base64 = base64Encode(bytes);
    html.AnchorElement(href: 'data:$mimeType;base64,$base64')
      ..setAttribute('download', fileName)
      ..click();
  }
}
