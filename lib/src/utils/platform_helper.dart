import 'dart:developer';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/foundation.dart';

String printPlatformDetails() {
  final platformDetails = PlatformHelper();
  if (platformDetails.isWeb) {
    log("Running on Web");
    return "web";
  } else if (platformDetails.isLinux) {
    log("Running on Linux");
    return "linux";
  } else if (platformDetails.isMacOS) {
    log("Running on macOS");
    return "macos";
  } else if (platformDetails.isIOS) {
    log("Running on iOS");
    return "ios";
  } else if (platformDetails.isAndroid) {
    log("Running on Android");
    return "android";
  } else if (platformDetails.isWindows) {
    log("Running on Windows");
    return "windows";
  } else if (platformDetails.isMobile) {
    log("Running on Mobile");
    return "mobile";
  }
  return "Unknown";
}

class PlatformHelper {
  static final PlatformHelper _singleton = PlatformHelper._internal();

  factory PlatformHelper() {
    return _singleton;
  }

  PlatformHelper._internal();

  bool get isWeb => kIsWeb;

  bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  bool get isMobile => 1.sw < 768;

  static bool get isDesktop => 1.sw > 768;
}
