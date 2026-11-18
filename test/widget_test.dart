import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/models/settings_model.dart';
import 'package:fldata/providers/theme_provider.dart';

void main() {
  test(
    'all palettes provide light/dark themes and pure black is dark-only',
    () {
      for (final palette in ColorStyle.values) {
        final settings = ThemeProps(palette: palette, pureBlack: true);
        expect(
          ThemeFactory.resolve(settings, Brightness.dark).colorScheme.surface,
          Colors.black,
        );
        expect(
          ThemeFactory.resolve(settings, Brightness.light).colorScheme.surface,
          isNot(Colors.black),
        );
        expect(ThemeProps.fromJson(settings.toJson()), settings);
      }
      expect(ThemeFactory.cacheSize, lessThanOrEqualTo(64));
    },
  );
}
