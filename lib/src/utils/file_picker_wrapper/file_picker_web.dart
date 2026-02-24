import 'package:file_picker/file_picker.dart';

class FilePickerWrapper {
  static Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // On web, path is null, bytes are available. But here we assume path is needed?
      // For web, om_data_grid might need to handle bytes instead of path.
      // But let's return path usually null on web.
      return result.files.single.path;
    }
    return null;
  }
}
