import 'dart:io';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FileViewer {
  static Future<void> open(String filePath) async {
    await OpenFile.open(filePath);
  }

  static Future<void> downloadAndOpen(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(filePath);
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
    await OpenFile.open(filePath);
  }
}
