import 'dart:async';
import 'dart:isolate';

class IsolateHelper {
  /// Runs [computation] in a separate isolate (on platforms that support it)
  /// and returns the result.
  ///
  /// On the web (JS), this runs on the main thread to avoid blocking.
  /// On the web (Wasm) and native platforms, this uses [Isolate.run].
  static Future<R> run<R>(FutureOr<R> Function() computation,
      {String? debugLabel}) async {
    // Isolate.run is available since Dart 2.19 and works on:
    // - Native (VM): Spawns an isolate.
    // - Web (Wasm): Spawns a thread (parallel).
    // - Web (JS): Runs on main thread (serial).
    // We prefer Isolate.run over compute() as it has less overhead.
    return await Isolate.run(computation, debugName: debugLabel);
  }
}
