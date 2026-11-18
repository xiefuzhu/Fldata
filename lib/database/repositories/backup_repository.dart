import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:drift/drift.dart';
import '../../enum/ds_enums.dart';
import '../../curriculum/catalog.dart';
import '../app_database.dart';
import 'quiz_repository.dart';
import 'achievement_repository.dart';
import '../../models/study_badge.dart';

/// Version 1 payload rows use SQLite column names and UTC Unix seconds.
class BackupRepository {
  BackupRepository(this.db, {Map<ChapterId, int>? moduleTotals})
    : moduleTotals =
          moduleTotals ?? {for (final c in chapters) c.id: c.moduleIds.length};
  final AppDatabase db;
  final Map<ChapterId, int> moduleTotals;
  static const tables = <String, String>{
    'lessonProgress': 'lesson_progress_table',
    'quizAttempts': 'quiz_attempts_table',
    'wrongQuestionBook': 'wrong_question_book_table',
    'chapterMastery': 'chapter_mastery_table',
    'dailyStudyStats': 'daily_study_stats_table',
    'userCustomDatasets': 'user_custom_datasets_table',
    'codeDrafts': 'code_drafts_table',
    'achievements': 'achievements_table',
  };
  Future<List<Map<String, dynamic>>> _rows(String table) async =>
      (await db.customSelect('SELECT * FROM $table').get())
          .map((r) => Map.of(r.data))
          .toList();
  Future<String> exportJson() => db.transaction(() async {
    final payload = <String, dynamic>{};
    final evidence = <String, int>{};
    for (final entry in tables.entries) {
      final rows = await _rows(entry.value);
      if (entry.key == 'achievements') {
        for (final row in rows) {
          final mask = row.remove('evidence_mask') as int;
          if (mask != 0) evidence[row['achievement_id'] as String] = mask;
        }
      }
      payload[entry.key] = rows;
    }
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'app': 'fldata',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'sourcePlatform': Platform.operatingSystem,
      'payload': payload,
      if (evidence.isNotEmpty) 'achievementEvidence': evidence,
    });
  });

  Future<void> importJson(
    String source, {
    ImportStrategy strategy = ImportStrategy.mergePreferHigher,
  }) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        (decoded['app'] != 'fldata' && decoded['app'] != 'struct_clash') ||
        decoded['schemaVersion'] != 1 ||
        decoded['payload'] is! Map<String, dynamic>) {
      throw const FormatException('不是受支持的 Fldata v1 备份');
    }
    final payload = decoded['payload'] as Map<String, dynamic>;
    final evidence = decoded['achievementEvidence'] ?? <String, dynamic>{};
    if (evidence is! Map<String, dynamic>) {
      throw const FormatException('成就分项记录格式错误');
    }
    final validated = <String, List<Map<String, dynamic>>>{};
    for (final entry in tables.entries) {
      final rows = payload[entry.key];
      if (rows is! List) throw FormatException('备份缺少完整数据表：${entry.key}');
      final columns = await db
          .customSelect('PRAGMA table_info(${entry.value})')
          .get();
      final names = columns.map((c) => c.data['name'] as String).toSet();
      validated[entry.value] = [];
      final primaryKeys = columns
          .where((c) => (c.data['pk'] as int) > 0)
          .map((c) => c.data['name'] as String)
          .toList();
      final seen = <String>{};
      for (final raw in rows) {
        if (entry.key == 'achievements' && raw is Map<String, dynamic>) {
          raw['evidence_mask'] = evidence[raw['achievement_id']] ?? 0;
        }
        if (raw is! Map<String, dynamic> ||
            raw.keys.toSet().difference(names).isNotEmpty ||
            names.difference(raw.keys.toSet()).isNotEmpty) {
          throw FormatException('备份列不匹配：${entry.key}');
        }
        for (final column in columns) {
          final c = column.data;
          final value = raw[c['name']];
          if (value == null) {
            if (c['notnull'] == 1 || c['pk'] == 1) {
              throw FormatException('备份缺少必填值：${c['name']}');
            }
          } else {
            final type = c['type'].toString().toUpperCase();
            if ((type == 'TEXT' && value is! String) ||
                (type == 'INTEGER' && value is! int) ||
                (type == 'REAL' && (value is! num || !value.isFinite))) {
              throw FormatException('备份字段类型错误：${c['name']}');
            }
          }
        }
        final identity = jsonEncode(
          primaryKeys.map((key) => raw[key]).toList(),
        );
        if (!seen.add(identity)) throw const FormatException('备份包含重复主键');
        for (final key in ['user_answer_json', 'payload_json']) {
          if (raw.containsKey(key) &&
              jsonDecode(raw[key] as String) is! Map<String, dynamic>) {
            throw const FormatException('备份中的答案或数据集必须是 JSON 对象');
          }
        }
        validated[entry.value]!.add(Map.of(raw));
      }
    }
    await db.transaction(() async {
      if (strategy == ImportStrategy.overwrite) {
        for (final table in tables.values) {
          await db.customStatement('DELETE FROM $table');
        }
      }
      for (final table in tables.values) {
        final existing = await _rows(table);
        for (final incoming in validated[table]!) {
          var row = Map<String, dynamic>.of(incoming);
          if (strategy == ImportStrategy.mergePreferHigher) {
            final key = switch (table) {
              'lesson_progress_table' => 'module_id',
              'wrong_question_book_table' ||
              'code_drafts_table' => 'question_id',
              'chapter_mastery_table' => 'chapter_id',
              'daily_study_stats_table' => 'date_key',
              'achievements_table' => 'achievement_id',
              _ => 'id',
            };
            if (table == 'quiz_attempts_table') {
              final fields = row.keys.where((k) => k != 'id');
              if (existing.any(
                (old) => fields.every((k) => old[k] == row[k]),
              )) {
                continue;
              }
              row.remove('id');
            } else if (table == 'user_custom_datasets_table') {
              if (existing.any(
                (old) =>
                    old['module_id'] == row['module_id'] &&
                    old['name'] == row['name'],
              )) {
                continue;
              }
              row.remove('id');
            } else {
              final matches = existing.where((old) => old[key] == row[key]);
              if (matches.isNotEmpty) row = _merge(table, matches.first, row);
            }
          }
          final names = row.keys.toList();
          await db.customStatement(
            'INSERT OR REPLACE INTO $table (${names.join(',')}) VALUES (${List.filled(names.length, '?').join(',')})',
            names.map((key) => row[key]).toList(),
          );
          existing.add(row);
        }
      }
      await QuizRepository(db).recomputeMastery(moduleTotals);
      await AchievementRepository(db).reconcile();
      db.notifyUpdates(
        tables.values.map((table) => TableUpdate(table)).toSet(),
      );
    });
  }

  Map<String, dynamic> _merge(
    String table,
    Map<String, dynamic> old,
    Map<String, dynamic> incoming,
  ) {
    num highest(String key) => math.max(old[key] as num, incoming[key] as num);
    switch (table) {
      case 'lesson_progress_table':
        return {
          ...incoming,
          'status': highest('status'),
          'time_spent_seconds':
              (old['time_spent_seconds'] as int) +
              (incoming['time_spent_seconds'] as int),
          'custom_run_count': highest('custom_run_count'),
          'watched_full_trace': highest('watched_full_trace'),
          'last_visited_at': highest('last_visited_at'),
        };
      case 'daily_study_stats_table':
        return {
          ...incoming,
          for (final k in [
            'study_seconds',
            'study_minutes',
            'labs_completed',
            'questions_solved',
            'correct_count',
          ])
            k: highest(k),
        };
      case 'code_drafts_table':
      case 'chapter_mastery_table':
        return (incoming['updated_at'] as int) > (old['updated_at'] as int)
            ? incoming
            : old;
      case 'wrong_question_book_table':
        // Keep the more conservative due date; no last-reviewed timestamp exists in v1.
        final selected =
            (incoming['next_review_at'] as int) < (old['next_review_at'] as int)
            ? incoming
            : old;
        return {...selected, 'error_count': highest('error_count')};
      case 'achievements_table':
        final dates = [
          old['unlocked_at'],
          incoming['unlocked_at'],
        ].whereType<int>();
        final mask =
            (old['evidence_mask'] as int) | (incoming['evidence_mask'] as int);
        final badge = StudyBadge.values
            .where((b) => b.id == incoming['achievement_id'])
            .firstOrNull;
        final multi =
            badge == StudyBadge.eulerWalker || badge == StudyBadge.avlBalancer;
        final previous = highest('progress_current').toInt();
        final count = multi
            ? math.max(
                previous,
                [
                  for (var i = 0; i < badge!.target; i++)
                    if ((mask & (1 << i)) != 0) i,
                ].length,
              )
            : previous;
        return {
          ...incoming,
          'evidence_mask': mask,
          'progress_current': count,
          'unlocked_at': dates.isNotEmpty
              ? dates.reduce(math.min)
              : badge?.reached(count, mask) == true
              ? DateTime.now().millisecondsSinceEpoch ~/ 1000
              : null,
        };
      default:
        return incoming;
    }
  }
}
