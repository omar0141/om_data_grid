import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'file_viewer_mobile.dart' if (dart.library.io) 'file_viewer_mobile.dart'
    as mobile;
import 'file_viewer_desktop.dart'
    if (dart.library.io) 'file_viewer_desktop.dart' as desktop;

class FileViewer {
  static Future<void> open(String filePath) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await mobile.FileViewerMobile.open(filePath);
    } else {
      await desktop.FileViewerDesktop.open(filePath);
    }
  }

  static Future<void> downloadAndOpen(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        await open(filePath);
      }
    } catch (e) {
      debugPrint("Download error: $e");
    }
  }

  static Future<void> saveAndOpen(
      List<int> bytes, String fileName, String mimeType) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    await open(filePath);
  }
}
