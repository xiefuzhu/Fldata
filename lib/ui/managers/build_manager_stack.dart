import 'playback_actions.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import '../../common/platform_detector.dart';
import '../../providers/app_providers.dart';
import '../../models/settings_model.dart';

class OpenCommandIntent extends Intent {
  const OpenCommandIntent();
}

class PageSearchIntent extends Intent {
  const PageSearchIntent();
}

class HotKeyManager extends StatelessWidget {
  const HotKeyManager({
    super.key,
    required this.child,
    required this.openCommand,
  });
  final Widget child;
  final VoidCallback openCommand;
  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: {
      ...playbackShortcuts,
      SingleActivator(
        LogicalKeyboardKey.keyK,
        control: !PlatformDetector.isMacOS,
        meta: PlatformDetector.isMacOS,
      ): const OpenCommandIntent(),
      SingleActivator(
        LogicalKeyboardKey.keyF,
        control: !PlatformDetector.isMacOS,
        meta: PlatformDetector.isMacOS,
      ): const PageSearchIntent(),
    },
    child: Actions(
      actions: {
        OpenCommandIntent: CallbackAction<OpenCommandIntent>(
          onInvoke: (_) {
            openCommand();
            return null;
          },
        ),
      },
      child: child,
    ),
  );
}

class BuildManagerStack extends StatelessWidget {
  const BuildManagerStack({
    super.key,
    required this.child,
    required this.openCommand,
    this.nativeWindow = true,
  });
  final Widget child;
  final VoidCallback openCommand;
  final bool nativeWindow;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: HotKeyManager(
      openCommand: openCommand,
      child: ThemeManager(
        nativeWindow: nativeWindow,
        child: WindowHeaderManager(
          nativeWindow: nativeWindow,
          openCommand: openCommand,
          child: child,
        ),
      ),
    ),
  );
}

class ThemeManager extends ConsumerStatefulWidget {
  const ThemeManager({
    super.key,
    required this.child,
    required this.nativeWindow,
  });
  final Widget child;
  final bool nativeWindow;
  @override
  ConsumerState<ThemeManager> createState() => _ThemeManagerState();
}

class _ThemeManagerState extends ConsumerState<ThemeManager> {
  (bool, bool)? applied;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final translucent = ref.watch(themeSettingsProvider).translucentSidebar;
    final next = (translucent, dark);
    if (widget.nativeWindow && PlatformDetector.isDesktop && applied != next) {
      applied = next;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          await applyWindowMaterial(translucent, dark);
        } on PlatformException catch (error) {
          debugPrint('Window material unavailable: ${error.code}');
        }
      });
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: widget.child,
    );
  }
}

class WindowHeaderManager extends ConsumerStatefulWidget {
  const WindowHeaderManager({
    super.key,
    required this.child,
    required this.openCommand,
    required this.nativeWindow,
  });
  final Widget child;
  final VoidCallback openCommand;
  final bool nativeWindow;
  @override
  ConsumerState<WindowHeaderManager> createState() =>
      _WindowHeaderManagerState();
}

class _WindowHeaderManagerState extends ConsumerState<WindowHeaderManager>
    with WindowListener {
  bool get active => widget.nativeWindow && PlatformDetector.isDesktop;
  @override
  void initState() {
    super.initState();
    if (active) windowManager.addListener(this);
  }

  @override
  void dispose() {
    if (active) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResized() async {
    if (await windowManager.isMaximized()) return;
    final size = await windowManager.getSize();
    if (!mounted) return;
    await ref
        .read(preferencesProvider)
        .setString(
          'window',
          jsonEncode(
            WindowProps(width: size.width, height: size.height).toJson(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!active) return widget.child;
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              if (PlatformDetector.isMacOS) const SizedBox(width: 76),
              Expanded(
                child: DragToMoveArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_tree_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Fldata',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.openCommand,
                child: Text('搜索  ${PlatformDetector.shortcutModifier} K'),
              ),
              if (PlatformDetector.isWindows) ...[
                IconButton(
                  tooltip: '最小化',
                  iconSize: 18,
                  onPressed: windowManager.minimize,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  tooltip: '最大化 / 还原',
                  iconSize: 16,
                  onPressed: () async {
                    if (await windowManager.isMaximized()) {
                      await windowManager.unmaximize();
                    } else {
                      await windowManager.maximize();
                    }
                  },
                  icon: const Icon(Icons.crop_square),
                ),
                IconButton(
                  tooltip: '关闭',
                  iconSize: 18,
                  onPressed: windowManager.close,
                  icon: const Icon(Icons.close),
                ),
              ],
            ],
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

Future<void> applyWindowMaterial(bool enabled, bool dark) async {
  if (!PlatformDetector.isDesktop) return;
  if (PlatformDetector.isWindows) {
    // Windows reports a build number in the platform version string.
    final match = RegExp(
      r'(?:Build |build |10\.0\.)([0-9]+)',
    ).firstMatch(Platform.operatingSystemVersion);
    final build = int.tryParse(match?.group(1) ?? '') ?? 0;
    await acrylic.Window.setEffect(
      effect: enabled && build >= 22621
          ? acrylic.WindowEffect.mica
          : acrylic.WindowEffect.solid,
      dark: dark,
    );
  } else if (PlatformDetector.isMacOS) {
    await acrylic.Window.setEffect(
      effect: enabled
          ? acrylic.WindowEffect.sidebar
          : acrylic.WindowEffect.solid,
      dark: dark,
    );
  }
}
