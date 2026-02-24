import 'dart:async';
import 'package:flutter/foundation.dart';

class IsolateHelper {
  static Future<R> run<R>(FutureOr<R> Function() computation,
      {String? debugLabel}) async {
    // If we are on web, we cannot spawn isolates like on VM.
    // However, Future.sync or just calling the function is fine.
    // Since kIsWeb covers Wasm as well in recent Flutter versions.
    if (kIsWeb) {
      return await computation();
    } else {
      // Use compute as a wrapper for Isolate.run which handles fallback or better yet,
      // create a separate conditional import if Isolate.run is strictly VM only.
      // But compute() from foundation is web-safe.
      return await compute((_) => computation(), null);
    }
  }
}
