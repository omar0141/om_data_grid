import 'package:url_launcher/url_launcher.dart';

class FileViewerDesktop {
  static Future<void> open(String filePath) async {
    final Uri uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
