import 'package:file_selector/file_selector.dart';

class FilePickerWrapper {
  static Future<String?> pickFile() async {
    final XFile? file = await openFile();
    if (file != null) {
      return file.path;
    }
    return null;
  }
}
