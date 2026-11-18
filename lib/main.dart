import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'application.dart';
import 'common/platform_detector.dart';
import 'models/settings_model.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  if (PlatformDetector.isDesktop) {
    await windowManager.ensureInitialized();
    await acrylic.Window.initialize();
    var saved = const WindowProps();
    final raw = preferences.getString('window');
    if (raw != null) {
      try {
        saved = WindowProps.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } on FormatException {
        saved = const WindowProps();
      }
    }
    final options = WindowOptions(
      size: Size(saved.width.clamp(800, 2560), saved.height.clamp(600, 1600)),
      minimumSize: const Size(800, 600),
      center: true,
      title: 'Fldata',
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: PlatformDetector.isMacOS,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(
    ProviderScope(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
      child: const FldataApp(),
    ),
  );
}
