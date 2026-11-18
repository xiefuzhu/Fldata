import 'package:drift/drift.dart';
import '../app_database.dart';

class DatasetRepository {
  const DatasetRepository(this.db);
  final AppDatabase db;
  Stream<List<UserCustomDataset>> watchAll() =>
      (db.select(db.userCustomDatasetsTable)..orderBy([
            (d) => OrderingTerm.asc(d.moduleId),
            (d) => OrderingTerm.asc(d.name),
          ]))
          .watch();

  Future<void> save(
    String moduleId,
    String name,
    Map<String, dynamic> payload, {
    int? id,
  }) => db.transaction(() async {
    final title = name.trim();
    if (title.isEmpty) throw const FormatException('请输入数据集名称。');
    final table = db.userCustomDatasetsTable;
    final existing =
        await (db.select(
              table,
            )..where((d) => d.moduleId.equals(moduleId) & d.name.equals(title)))
            .getSingleOrNull();
    if (existing != null && existing.id != id) {
      throw const FormatException('这个课程已有同名数据集。');
    }
    if (id == null) {
      await db
          .into(table)
          .insert(
            UserCustomDatasetsTableCompanion.insert(
              moduleId: moduleId,
              name: title,
              payloadJson: payload,
              createdAt: DateTime.now(),
            ),
          );
    } else {
      final changed =
          await (db.update(
            table,
          )..where((d) => d.id.equals(id) & d.moduleId.equals(moduleId))).write(
            UserCustomDatasetsTableCompanion(
              name: Value(title),
              payloadJson: Value(payload),
            ),
          );
      if (changed == 0) throw const FormatException('此数据集已经移除。');
    }
  });
  Future<int> remove(int id) => (db.delete(
    db.userCustomDatasetsTable,
  )..where((d) => d.id.equals(id))).go();
}
