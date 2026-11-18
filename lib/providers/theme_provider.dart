import 'package:flutter/material.dart';
import '../enum/ds_enums.dart';
import '../models/settings_model.dart';
import '../ui/tokens/ds_semantic_colors.dart';

typedef DynamicColorSeeds = ({
  Color? lightSeed,
  Color? darkSeed,
  Color accentColor,
});

class ThemeFactory {
  static final _cache = <(ThemeProps, Brightness, Color?), ThemeData>{};
  static int get cacheSize => _cache.length;
  static ThemeData resolve(
    ThemeProps props,
    Brightness brightness, {
    Color? dynamicSeed,
  }) {
    final key = (props, brightness, dynamicSeed);
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }
    final seed = switch (props.palette) {
      ColorStyle.systemDynamic => dynamicSeed ?? const Color(0xFF006874),
      ColorStyle.textbookDualTone => const Color(0xFF006874),
      ColorStyle.clashBlue => const Color(0xFF1E65F3),
      ColorStyle.violetExpressive => const Color(0xFF6750A4),
      ColorStyle.emeraldForest => const Color(0xFF006C4C),
      ColorStyle.amberGold => const Color(0xFF8C5000),
      ColorStyle.roseCrimson => const Color(0xFF9C4146),
      ColorStyle.monochrome => const Color(0xFF606060),
    };
    var scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: props.palette == ColorStyle.monochrome
          ? DynamicSchemeVariant.monochrome
          : DynamicSchemeVariant.tonalSpot,
    );
    if (props.palette == ColorStyle.textbookDualTone) {
      final accent = ColorScheme.fromSeed(
        seedColor: const Color(0xFFD84315),
        brightness: brightness,
      );
      scheme = scheme.copyWith(
        tertiary: accent.primary,
        onTertiary: accent.onPrimary,
        tertiaryContainer: accent.primaryContainer,
        onTertiaryContainer: accent.onPrimaryContainer,
      );
    }
    if (props.pureBlack && brightness == Brightness.dark) {
      scheme = scheme.copyWith(
        surface: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0D0D10),
      );
    }
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [DsSemanticColors.fromScheme(scheme)],
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
    _cache[key] = theme;
    if (_cache.length > 64) _cache.remove(_cache.keys.first);
    return theme;
  }
}
