import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:fldata/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fldata/curriculum/catalog.dart';
import 'package:fldata/curriculum/dataset_catalog.dart';
import 'package:fldata/database/repositories/backup_repository.dart';
import 'package:fldata/database/repositories/dataset_repository.dart';
import 'package:fldata/enum/ds_enums.dart';
import 'package:fldata/providers/playback_provider.dart';
import 'package:fldata/router/app_router.dart';
import 'package:fldata/ui/layout/layout_preview.dart';
import '../curriculum/lesson_test_support.dart';
import 'package:fldata/views/settings/settings_view.dart';

void main() {
  test("dataset conflicts, rename and backup strategies", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DatasetRepository(db), backup = BackupRepository(db);
    await repo.save("ch1_struct_mapping", "四个位置", {"note": "preserve"});
    final row = (await repo.watchAll().first).single;
    final json = await backup.exportJson();
    await expectLater(
      repo.save(row.moduleId, row.name, {}),
      throwsFormatException,
    );
    await repo.save(row.moduleId, '改名', row.payloadJson, id: row.id);
    await backup.importJson(json);
    expect(await repo.watchAll().first, hasLength(2));
    await backup.importJson(json, strategy: ImportStrategy.overwrite);
    expect((await repo.watchAll().first).single.name, '四个位置');
  });
  test('every course exposes editable copies of its actual presets', () {
    expect(
      datasetModules.keys.toSet(),
      chapters.expand((c) => c.moduleIds).toSet(),
    );
    for (final module in datasetModules.values) {
      for (final preset in datasetPresets(module.id)) {
        final raw = datasetText(preset.input);
        final input = datasetInput(module, {'preset': preset.id, 'input': raw});
        expect(input.runtimeType, preset.input.runtimeType);
        expect(datasetText(input), raw);
      }
    }
  });
  testWidgets('copy, edit, launch and delete a dataset', (tester) async {
    final (container, db) = await mount(tester, const Size(1360, 900));
    final router = container.read(appRouterProvider);
    router.go('/settings');
    await tester.pumpAndSettle();
    final entry = find.text('实验数据集');
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.copy).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '四个位置');
    await tester.enterText(
      find.byType(TextField).last,
      'linear sequential 4 21',
    );
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('四个位置'), findsOneWidget);
    await tester.tap(find.byTooltip('运行 四个位置'));
    await tester.pumpAndSettle();
    final module = datasetModules['ch1_struct_mapping']!;
    final expected = module.generateTrace(
      module.validateInput('linear sequential 4 21').value!,
    );
    expect(container.read(playbackProvider).timeline, expected);
    router.pop();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除 四个位置'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(find.text('四个位置'), findsNothing);
    await leave(tester, container, db);
  });
  testWidgets(
    'preview retains navigation and supplies all three logical viewport sizes',
    (tester) async {
      final (container, db) = await mount(tester, const Size(1200, 900));
      final router = container.read(appRouterProvider);
      router.go('/settings');
      await tester.pumpAndSettle();
      for (final device in PreviewDevice.values) {
        final chip = find.byKey(ValueKey('preview-${device.name}'));
        await tester.scrollUntilVisible(
          chip,
          300,
          scrollable: find
              .descendant(
                of: find.byType(SettingsView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(
          MediaQuery.sizeOf(tester.element(find.byType(SettingsView))),
          device.size,
        );
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          '/settings',
        );
      }
      router.go('/catalog');
      await tester.pumpAndSettle();
      await tester.tap(find.text('退出预览'));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/catalog');
      expect(container.read(previewDeviceProvider), isNull);
      expect(tester.takeException(), isNull);
      await leave(tester, container, db);
    },
  );
}
