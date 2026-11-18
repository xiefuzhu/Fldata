import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

abstract final class PlatformDetector {
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isMobile => isAndroid || Platform.isIOS;
  static void selectionFeedback() {
    if (isMobile) unawaited(HapticFeedback.selectionClick());
  }

  static bool get isDesktop => isWindows || isMacOS || Platform.isLinux;
  static String get shortcutModifier => isMacOS ? '⌘' : 'Ctrl';
}
