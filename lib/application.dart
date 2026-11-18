import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enum/ds_enums.dart';
import 'providers/app_providers.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'ui/layout/layout_preview.dart';

class FldataApp extends ConsumerWidget {
  const FldataApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final router = ref.watch(appRouterProvider);
    return DynamicColorBuilder(
      builder: (light, dark) => MaterialApp.router(
        title: 'Fldata',
        debugShowCheckedModeBanner: false,
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeFactory.resolve(
          settings,
          Brightness.light,
          dynamicSeed: light?.primary,
        ),
        darkTheme: ThemeFactory.resolve(
          settings,
          Brightness.dark,
          dynamicSeed: dark?.primary,
        ),
        themeMode: switch (settings.mode) {
          AppearanceMode.system => ThemeMode.system,
          AppearanceMode.light => ThemeMode.light,
          AppearanceMode.dark => ThemeMode.dark,
        },
        builder: (_, child) => LayoutPreview(child: child!),
        routerConfig: router,
      ),
    );
  }
}
