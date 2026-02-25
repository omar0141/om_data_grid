import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class FileViewerDesktop {
  static Future<void> open(String filePath) async {
    try {
      final Uri uri = Uri.file(filePath);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Desktop file open error: $e");
    }
  }
}
