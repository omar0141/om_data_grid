import 'package:file_selector/file_selector.dart';

class FilePickerWrapper {
  static Future<String?> pickFile() async {
    final XFile? file = await openFile();
    if (file != null) {
      // In web, path might be a blob url or similar, XFile handles it well.
      // But for display it might be just the name or partial path.
      return file.path;
    }
    return null;
  }
}
