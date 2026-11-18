// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LessonProgressTableTable extends LessonProgressTable
    with TableInfo<$LessonProgressTableTable, LessonProgress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    check: () => ComparableExpr(status).isBetweenValues(0, 2),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _watchedFullTraceMeta = const VerificationMeta(
    'watchedFullTrace',
  );
  @override
  late final GeneratedColumn<bool> watchedFullTrace = GeneratedColumn<bool>(
    'watched_full_trace',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("watched_full_trace" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customRunCountMeta = const VerificationMeta(
    'customRunCount',
  );
  @override
  late final GeneratedColumn<int> customRunCount = GeneratedColumn<int>(
    'custom_run_count',
    aliasedName,
    false,
    check: () => ComparableExpr(customRunCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timeSpentSecondsMeta = const VerificationMeta(
    'timeSpentSeconds',
  );
  @override
  late final GeneratedColumn<int> timeSpentSeconds = GeneratedColumn<int>(
    'time_spent_seconds',
    aliasedName,
    false,
    check: () => ComparableExpr(timeSpentSeconds).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastVisitedAtMeta = const VerificationMeta(
    'lastVisitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVisitedAt =
      GeneratedColumn<DateTime>(
        'last_visited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    moduleId,
    chapterId,
    status,
    watchedFullTrace,
    customRunCount,
    timeSpentSeconds,
    lastVisitedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonProgress> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('watched_full_trace')) {
      context.handle(
        _watchedFullTraceMeta,
        watchedFullTrace.isAcceptableOrUnknown(
          data['watched_full_trace']!,
          _watchedFullTraceMeta,
        ),
      );
    }
    if (data.containsKey('custom_run_count')) {
      context.handle(
        _customRunCountMeta,
        customRunCount.isAcceptableOrUnknown(
          data['custom_run_count']!,
          _customRunCountMeta,
        ),
      );
    }
    if (data.containsKey('time_spent_seconds')) {
      context.handle(
        _timeSpentSecondsMeta,
        timeSpentSeconds.isAcceptableOrUnknown(
          data['time_spent_seconds']!,
          _timeSpentSecondsMeta,
        ),
      );
    }
    if (data.containsKey('last_visited_at')) {
      context.handle(
        _lastVisitedAtMeta,
        lastVisitedAt.isAcceptableOrUnknown(
          data['last_visited_at']!,
          _lastVisitedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastVisitedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId};
  @override
  LessonProgress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgress(
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      watchedFullTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}watched_full_trace'],
      )!,
      customRunCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_run_count'],
      )!,
      timeSpentSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_spent_seconds'],
      )!,
      lastVisitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_visited_at'],
      )!,
    );
  }

  @override
  $LessonProgressTableTable createAlias(String alias) {
    return $LessonProgressTableTable(attachedDatabase, alias);
  }
}

class LessonProgress extends DataClass implements Insertable<LessonProgress> {
  final String moduleId;
  final String chapterId;
  final int status;
  final bool watchedFullTrace;
  final int customRunCount;
  final int timeSpentSeconds;
  final DateTime lastVisitedAt;
  const LessonProgress({
    required this.moduleId,
    required this.chapterId,
    required this.status,
    required this.watchedFullTrace,
    required this.customRunCount,
    required this.timeSpentSeconds,
    required this.lastVisitedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['status'] = Variable<int>(status);
    map['watched_full_trace'] = Variable<bool>(watchedFullTrace);
    map['custom_run_count'] = Variable<int>(customRunCount);
    map['time_spent_seconds'] = Variable<int>(timeSpentSeconds);
    map['last_visited_at'] = Variable<DateTime>(lastVisitedAt);
    return map;
  }

  LessonProgressTableCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressTableCompanion(
      moduleId: Value(moduleId),
      chapterId: Value(chapterId),
      status: Value(status),
      watchedFullTrace: Value(watchedFullTrace),
      customRunCount: Value(customRunCount),
      timeSpentSeconds: Value(timeSpentSeconds),
      lastVisitedAt: Value(lastVisitedAt),
    );
  }

  factory LessonProgress.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgress(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      status: serializer.fromJson<int>(json['status']),
      watchedFullTrace: serializer.fromJson<bool>(json['watchedFullTrace']),
      customRunCount: serializer.fromJson<int>(json['customRunCount']),
      timeSpentSeconds: serializer.fromJson<int>(json['timeSpentSeconds']),
      lastVisitedAt: serializer.fromJson<DateTime>(json['lastVisitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'chapterId': serializer.toJson<String>(chapterId),
      'status': serializer.toJson<int>(status),
      'watchedFullTrace': serializer.toJson<bool>(watchedFullTrace),
      'customRunCount': serializer.toJson<int>(customRunCount),
      'timeSpentSeconds': serializer.toJson<int>(timeSpentSeconds),
      'lastVisitedAt': serializer.toJson<DateTime>(lastVisitedAt),
    };
  }

  LessonProgress copyWith({
    String? moduleId,
    String? chapterId,
    int? status,
    bool? watchedFullTrace,
    int? customRunCount,
    int? timeSpentSeconds,
    DateTime? lastVisitedAt,
  }) => LessonProgress(
    moduleId: moduleId ?? this.moduleId,
    chapterId: chapterId ?? this.chapterId,
    status: status ?? this.status,
    watchedFullTrace: watchedFullTrace ?? this.watchedFullTrace,
    customRunCount: customRunCount ?? this.customRunCount,
    timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
  );
  LessonProgress copyWithCompanion(LessonProgressTableCompanion data) {
    return LessonProgress(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      status: data.status.present ? data.status.value : this.status,
      watchedFullTrace: data.watchedFullTrace.present
          ? data.watchedFullTrace.value
          : this.watchedFullTrace,
      customRunCount: data.customRunCount.present
          ? data.customRunCount.value
          : this.customRunCount,
      timeSpentSeconds: data.timeSpentSeconds.present
          ? data.timeSpentSeconds.value
          : this.timeSpentSeconds,
      lastVisitedAt: data.lastVisitedAt.present
          ? data.lastVisitedAt.value
          : this.lastVisitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgress(')
          ..write('moduleId: $moduleId, ')
          ..write('chapterId: $chapterId, ')
          ..write('status: $status, ')
          ..write('watchedFullTrace: $watchedFullTrace, ')
          ..write('customRunCount: $customRunCount, ')
          ..write('timeSpentSeconds: $timeSpentSeconds, ')
          ..write('lastVisitedAt: $lastVisitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    moduleId,
    chapterId,
    status,
    watchedFullTrace,
    customRunCount,
    timeSpentSeconds,
    lastVisitedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgress &&
          other.moduleId == this.moduleId &&
          other.chapterId == this.chapterId &&
          other.status == this.status &&
          other.watchedFullTrace == this.watchedFullTrace &&
          other.customRunCount == this.customRunCount &&
          other.timeSpentSeconds == this.timeSpentSeconds &&
          other.lastVisitedAt == this.lastVisitedAt);
}

class LessonProgressTableCompanion extends UpdateCompanion<LessonProgress> {
  final Value<String> moduleId;
  final Value<String> chapterId;
  final Value<int> status;
  final Value<bool> watchedFullTrace;
  final Value<int> customRunCount;
  final Value<int> timeSpentSeconds;
  final Value<DateTime> lastVisitedAt;
  final Value<int> rowid;
  const LessonProgressTableCompanion({
    this.moduleId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.status = const Value.absent(),
    this.watchedFullTrace = const Value.absent(),
    this.customRunCount = const Value.absent(),
    this.timeSpentSeconds = const Value.absent(),
    this.lastVisitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressTableCompanion.insert({
    required String moduleId,
    required String chapterId,
    this.status = const Value.absent(),
    this.watchedFullTrace = const Value.absent(),
    this.customRunCount = const Value.absent(),
    this.timeSpentSeconds = const Value.absent(),
    required DateTime lastVisitedAt,
    this.rowid = const Value.absent(),
  }) : moduleId = Value(moduleId),
       chapterId = Value(chapterId),
       lastVisitedAt = Value(lastVisitedAt);
  static Insertable<LessonProgress> custom({
    Expression<String>? moduleId,
    Expression<String>? chapterId,
    Expression<int>? status,
    Expression<bool>? watchedFullTrace,
    Expression<int>? customRunCount,
    Expression<int>? timeSpentSeconds,
    Expression<DateTime>? lastVisitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (status != null) 'status': status,
      if (watchedFullTrace != null) 'watched_full_trace': watchedFullTrace,
      if (customRunCount != null) 'custom_run_count': customRunCount,
      if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
      if (lastVisitedAt != null) 'last_visited_at': lastVisitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressTableCompanion copyWith({
    Value<String>? moduleId,
    Value<String>? chapterId,
    Value<int>? status,
    Value<bool>? watchedFullTrace,
    Value<int>? customRunCount,
    Value<int>? timeSpentSeconds,
    Value<DateTime>? lastVisitedAt,
    Value<int>? rowid,
  }) {
    return LessonProgressTableCompanion(
      moduleId: moduleId ?? this.moduleId,
      chapterId: chapterId ?? this.chapterId,
      status: status ?? this.status,
      watchedFullTrace: watchedFullTrace ?? this.watchedFullTrace,
      customRunCount: customRunCount ?? this.customRunCount,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (watchedFullTrace.present) {
      map['watched_full_trace'] = Variable<bool>(watchedFullTrace.value);
    }
    if (customRunCount.present) {
      map['custom_run_count'] = Variable<int>(customRunCount.value);
    }
    if (timeSpentSeconds.present) {
      map['time_spent_seconds'] = Variable<int>(timeSpentSeconds.value);
    }
    if (lastVisitedAt.present) {
      map['last_visited_at'] = Variable<DateTime>(lastVisitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressTableCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('chapterId: $chapterId, ')
          ..write('status: $status, ')
          ..write('watchedFullTrace: $watchedFullTrace, ')
          ..write('customRunCount: $customRunCount, ')
          ..write('timeSpentSeconds: $timeSpentSeconds, ')
          ..write('lastVisitedAt: $lastVisitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizAttemptsTableTable extends QuizAttemptsTable
    with TableInfo<$QuizAttemptsTableTable, QuizAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAttemptsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTypeMeta = const VerificationMeta(
    'questionType',
  );
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
    'question_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    check: () => ComparableExpr(score).isBetweenValues(0, 100),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  userAnswerJson =
      GeneratedColumn<String>(
        'user_answer_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, dynamic>>(
        $QuizAttemptsTableTable.$converteruserAnswerJson,
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    check: () => ComparableExpr(durationMs).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptedAtMeta = const VerificationMeta(
    'attemptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> attemptedAt = GeneratedColumn<DateTime>(
    'attempted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionId,
    chapterId,
    questionType,
    isCorrect,
    score,
    userAnswerJson,
    durationMs,
    attemptedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
        _questionTypeMeta,
        questionType.isAcceptableOrUnknown(
          data['question_type']!,
          _questionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTypeMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('attempted_at')) {
      context.handle(
        _attemptedAtMeta,
        attemptedAt.isAcceptableOrUnknown(
          data['attempted_at']!,
          _attemptedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      questionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_type'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      userAnswerJson: $QuizAttemptsTableTable.$converteruserAnswerJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}user_answer_json'],
        )!,
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      attemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attempted_at'],
      )!,
    );
  }

  @override
  $QuizAttemptsTableTable createAlias(String alias) {
    return $QuizAttemptsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converteruserAnswerJson =
      const JsonMapConverter();
}

class QuizAttempt extends DataClass implements Insertable<QuizAttempt> {
  final int id;
  final String questionId;
  final String chapterId;
  final String questionType;
  final bool isCorrect;
  final int score;
  final Map<String, dynamic> userAnswerJson;
  final int durationMs;
  final DateTime attemptedAt;
  const QuizAttempt({
    required this.id,
    required this.questionId,
    required this.chapterId,
    required this.questionType,
    required this.isCorrect,
    required this.score,
    required this.userAnswerJson,
    required this.durationMs,
    required this.attemptedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<String>(questionId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['question_type'] = Variable<String>(questionType);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['score'] = Variable<int>(score);
    {
      map['user_answer_json'] = Variable<String>(
        $QuizAttemptsTableTable.$converteruserAnswerJson.toSql(userAnswerJson),
      );
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['attempted_at'] = Variable<DateTime>(attemptedAt);
    return map;
  }

  QuizAttemptsTableCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptsTableCompanion(
      id: Value(id),
      questionId: Value(questionId),
      chapterId: Value(chapterId),
      questionType: Value(questionType),
      isCorrect: Value(isCorrect),
      score: Value(score),
      userAnswerJson: Value(userAnswerJson),
      durationMs: Value(durationMs),
      attemptedAt: Value(attemptedAt),
    );
  }

  factory QuizAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttempt(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      questionType: serializer.fromJson<String>(json['questionType']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      score: serializer.fromJson<int>(json['score']),
      userAnswerJson: serializer.fromJson<Map<String, dynamic>>(
        json['userAnswerJson'],
      ),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      attemptedAt: serializer.fromJson<DateTime>(json['attemptedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<String>(questionId),
      'chapterId': serializer.toJson<String>(chapterId),
      'questionType': serializer.toJson<String>(questionType),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'score': serializer.toJson<int>(score),
      'userAnswerJson': serializer.toJson<Map<String, dynamic>>(userAnswerJson),
      'durationMs': serializer.toJson<int>(durationMs),
      'attemptedAt': serializer.toJson<DateTime>(attemptedAt),
    };
  }

  QuizAttempt copyWith({
    int? id,
    String? questionId,
    String? chapterId,
    String? questionType,
    bool? isCorrect,
    int? score,
    Map<String, dynamic>? userAnswerJson,
    int? durationMs,
    DateTime? attemptedAt,
  }) => QuizAttempt(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    chapterId: chapterId ?? this.chapterId,
    questionType: questionType ?? this.questionType,
    isCorrect: isCorrect ?? this.isCorrect,
    score: score ?? this.score,
    userAnswerJson: userAnswerJson ?? this.userAnswerJson,
    durationMs: durationMs ?? this.durationMs,
    attemptedAt: attemptedAt ?? this.attemptedAt,
  );
  QuizAttempt copyWithCompanion(QuizAttemptsTableCompanion data) {
    return QuizAttempt(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      score: data.score.present ? data.score.value : this.score,
      userAnswerJson: data.userAnswerJson.present
          ? data.userAnswerJson.value
          : this.userAnswerJson,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      attemptedAt: data.attemptedAt.present
          ? data.attemptedAt.value
          : this.attemptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttempt(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('questionType: $questionType, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('score: $score, ')
          ..write('userAnswerJson: $userAnswerJson, ')
          ..write('durationMs: $durationMs, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    questionId,
    chapterId,
    questionType,
    isCorrect,
    score,
    userAnswerJson,
    durationMs,
    attemptedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttempt &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.chapterId == this.chapterId &&
          other.questionType == this.questionType &&
          other.isCorrect == this.isCorrect &&
          other.score == this.score &&
          other.userAnswerJson == this.userAnswerJson &&
          other.durationMs == this.durationMs &&
          other.attemptedAt == this.attemptedAt);
}

class QuizAttemptsTableCompanion extends UpdateCompanion<QuizAttempt> {
  final Value<int> id;
  final Value<String> questionId;
  final Value<String> chapterId;
  final Value<String> questionType;
  final Value<bool> isCorrect;
  final Value<int> score;
  final Value<Map<String, dynamic>> userAnswerJson;
  final Value<int> durationMs;
  final Value<DateTime> attemptedAt;
  const QuizAttemptsTableCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.questionType = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.score = const Value.absent(),
    this.userAnswerJson = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.attemptedAt = const Value.absent(),
  });
  QuizAttemptsTableCompanion.insert({
    this.id = const Value.absent(),
    required String questionId,
    required String chapterId,
    required String questionType,
    required bool isCorrect,
    required int score,
    required Map<String, dynamic> userAnswerJson,
    required int durationMs,
    required DateTime attemptedAt,
  }) : questionId = Value(questionId),
       chapterId = Value(chapterId),
       questionType = Value(questionType),
       isCorrect = Value(isCorrect),
       score = Value(score),
       userAnswerJson = Value(userAnswerJson),
       durationMs = Value(durationMs),
       attemptedAt = Value(attemptedAt);
  static Insertable<QuizAttempt> custom({
    Expression<int>? id,
    Expression<String>? questionId,
    Expression<String>? chapterId,
    Expression<String>? questionType,
    Expression<bool>? isCorrect,
    Expression<int>? score,
    Expression<String>? userAnswerJson,
    Expression<int>? durationMs,
    Expression<DateTime>? attemptedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (questionType != null) 'question_type': questionType,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (score != null) 'score': score,
      if (userAnswerJson != null) 'user_answer_json': userAnswerJson,
      if (durationMs != null) 'duration_ms': durationMs,
      if (attemptedAt != null) 'attempted_at': attemptedAt,
    });
  }

  QuizAttemptsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? questionId,
    Value<String>? chapterId,
    Value<String>? questionType,
    Value<bool>? isCorrect,
    Value<int>? score,
    Value<Map<String, dynamic>>? userAnswerJson,
    Value<int>? durationMs,
    Value<DateTime>? attemptedAt,
  }) {
    return QuizAttemptsTableCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      chapterId: chapterId ?? this.chapterId,
      questionType: questionType ?? this.questionType,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      userAnswerJson: userAnswerJson ?? this.userAnswerJson,
      durationMs: durationMs ?? this.durationMs,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (userAnswerJson.present) {
      map['user_answer_json'] = Variable<String>(
        $QuizAttemptsTableTable.$converteruserAnswerJson.toSql(
          userAnswerJson.value,
        ),
      );
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (attemptedAt.present) {
      map['attempted_at'] = Variable<DateTime>(attemptedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptsTableCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('questionType: $questionType, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('score: $score, ')
          ..write('userAnswerJson: $userAnswerJson, ')
          ..write('durationMs: $durationMs, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }
}

class $WrongQuestionBookTableTable extends WrongQuestionBookTable
    with TableInfo<$WrongQuestionBookTableTable, WrongQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WrongQuestionBookTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCountMeta = const VerificationMeta(
    'errorCount',
  );
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
    'error_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _consecutiveCorrectMeta =
      const VerificationMeta('consecutiveCorrect');
  @override
  late final GeneratedColumn<int> consecutiveCorrect = GeneratedColumn<int>(
    'consecutive_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easinessFactorMeta = const VerificationMeta(
    'easinessFactor',
  );
  @override
  late final GeneratedColumn<double> easinessFactor = GeneratedColumn<double>(
    'easiness_factor',
    aliasedName,
    false,
    check: () => ComparableExpr(easinessFactor).isBiggerOrEqualValue(1.3),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    check: () => ComparableExpr(intervalDays).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNoteMeta = const VerificationMeta(
    'userNote',
  );
  @override
  late final GeneratedColumn<String> userNote = GeneratedColumn<String>(
    'user_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isMasteredMeta = const VerificationMeta(
    'isMastered',
  );
  @override
  late final GeneratedColumn<bool> isMastered = GeneratedColumn<bool>(
    'is_mastered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mastered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    chapterId,
    errorCount,
    consecutiveCorrect,
    easinessFactor,
    intervalDays,
    nextReviewAt,
    userNote,
    isMastered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wrong_question_book_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WrongQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    if (data.containsKey('consecutive_correct')) {
      context.handle(
        _consecutiveCorrectMeta,
        consecutiveCorrect.isAcceptableOrUnknown(
          data['consecutive_correct']!,
          _consecutiveCorrectMeta,
        ),
      );
    }
    if (data.containsKey('easiness_factor')) {
      context.handle(
        _easinessFactorMeta,
        easinessFactor.isAcceptableOrUnknown(
          data['easiness_factor']!,
          _easinessFactorMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
    }
    if (data.containsKey('user_note')) {
      context.handle(
        _userNoteMeta,
        userNote.isAcceptableOrUnknown(data['user_note']!, _userNoteMeta),
      );
    }
    if (data.containsKey('is_mastered')) {
      context.handle(
        _isMasteredMeta,
        isMastered.isAcceptableOrUnknown(data['is_mastered']!, _isMasteredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  WrongQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WrongQuestion(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
      consecutiveCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_correct'],
      )!,
      easinessFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}easiness_factor'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      )!,
      userNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_note'],
      )!,
      isMastered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mastered'],
      )!,
    );
  }

  @override
  $WrongQuestionBookTableTable createAlias(String alias) {
    return $WrongQuestionBookTableTable(attachedDatabase, alias);
  }
}

class WrongQuestion extends DataClass implements Insertable<WrongQuestion> {
  final String questionId;
  final String chapterId;
  final int errorCount;
  final int consecutiveCorrect;
  final double easinessFactor;
  final int intervalDays;
  final DateTime nextReviewAt;
  final String userNote;
  final bool isMastered;
  const WrongQuestion({
    required this.questionId,
    required this.chapterId,
    required this.errorCount,
    required this.consecutiveCorrect,
    required this.easinessFactor,
    required this.intervalDays,
    required this.nextReviewAt,
    required this.userNote,
    required this.isMastered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['error_count'] = Variable<int>(errorCount);
    map['consecutive_correct'] = Variable<int>(consecutiveCorrect);
    map['easiness_factor'] = Variable<double>(easinessFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    map['user_note'] = Variable<String>(userNote);
    map['is_mastered'] = Variable<bool>(isMastered);
    return map;
  }

  WrongQuestionBookTableCompanion toCompanion(bool nullToAbsent) {
    return WrongQuestionBookTableCompanion(
      questionId: Value(questionId),
      chapterId: Value(chapterId),
      errorCount: Value(errorCount),
      consecutiveCorrect: Value(consecutiveCorrect),
      easinessFactor: Value(easinessFactor),
      intervalDays: Value(intervalDays),
      nextReviewAt: Value(nextReviewAt),
      userNote: Value(userNote),
      isMastered: Value(isMastered),
    );
  }

  factory WrongQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WrongQuestion(
      questionId: serializer.fromJson<String>(json['questionId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      consecutiveCorrect: serializer.fromJson<int>(json['consecutiveCorrect']),
      easinessFactor: serializer.fromJson<double>(json['easinessFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
      userNote: serializer.fromJson<String>(json['userNote']),
      isMastered: serializer.fromJson<bool>(json['isMastered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'chapterId': serializer.toJson<String>(chapterId),
      'errorCount': serializer.toJson<int>(errorCount),
      'consecutiveCorrect': serializer.toJson<int>(consecutiveCorrect),
      'easinessFactor': serializer.toJson<double>(easinessFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
      'userNote': serializer.toJson<String>(userNote),
      'isMastered': serializer.toJson<bool>(isMastered),
    };
  }

  WrongQuestion copyWith({
    String? questionId,
    String? chapterId,
    int? errorCount,
    int? consecutiveCorrect,
    double? easinessFactor,
    int? intervalDays,
    DateTime? nextReviewAt,
    String? userNote,
    bool? isMastered,
  }) => WrongQuestion(
    questionId: questionId ?? this.questionId,
    chapterId: chapterId ?? this.chapterId,
    errorCount: errorCount ?? this.errorCount,
    consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
    easinessFactor: easinessFactor ?? this.easinessFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    userNote: userNote ?? this.userNote,
    isMastered: isMastered ?? this.isMastered,
  );
  WrongQuestion copyWithCompanion(WrongQuestionBookTableCompanion data) {
    return WrongQuestion(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
      consecutiveCorrect: data.consecutiveCorrect.present
          ? data.consecutiveCorrect.value
          : this.consecutiveCorrect,
      easinessFactor: data.easinessFactor.present
          ? data.easinessFactor.value
          : this.easinessFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      userNote: data.userNote.present ? data.userNote.value : this.userNote,
      isMastered: data.isMastered.present
          ? data.isMastered.value
          : this.isMastered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WrongQuestion(')
          ..write('questionId: $questionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('errorCount: $errorCount, ')
          ..write('consecutiveCorrect: $consecutiveCorrect, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('userNote: $userNote, ')
          ..write('isMastered: $isMastered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    questionId,
    chapterId,
    errorCount,
    consecutiveCorrect,
    easinessFactor,
    intervalDays,
    nextReviewAt,
    userNote,
    isMastered,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WrongQuestion &&
          other.questionId == this.questionId &&
          other.chapterId == this.chapterId &&
          other.errorCount == this.errorCount &&
          other.consecutiveCorrect == this.consecutiveCorrect &&
          other.easinessFactor == this.easinessFactor &&
          other.intervalDays == this.intervalDays &&
          other.nextReviewAt == this.nextReviewAt &&
          other.userNote == this.userNote &&
          other.isMastered == this.isMastered);
}

class WrongQuestionBookTableCompanion extends UpdateCompanion<WrongQuestion> {
  final Value<String> questionId;
  final Value<String> chapterId;
  final Value<int> errorCount;
  final Value<int> consecutiveCorrect;
  final Value<double> easinessFactor;
  final Value<int> intervalDays;
  final Value<DateTime> nextReviewAt;
  final Value<String> userNote;
  final Value<bool> isMastered;
  final Value<int> rowid;
  const WrongQuestionBookTableCompanion({
    this.questionId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.consecutiveCorrect = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.userNote = const Value.absent(),
    this.isMastered = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WrongQuestionBookTableCompanion.insert({
    required String questionId,
    required String chapterId,
    this.errorCount = const Value.absent(),
    this.consecutiveCorrect = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    required DateTime nextReviewAt,
    this.userNote = const Value.absent(),
    this.isMastered = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       chapterId = Value(chapterId),
       nextReviewAt = Value(nextReviewAt);
  static Insertable<WrongQuestion> custom({
    Expression<String>? questionId,
    Expression<String>? chapterId,
    Expression<int>? errorCount,
    Expression<int>? consecutiveCorrect,
    Expression<double>? easinessFactor,
    Expression<int>? intervalDays,
    Expression<DateTime>? nextReviewAt,
    Expression<String>? userNote,
    Expression<bool>? isMastered,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (errorCount != null) 'error_count': errorCount,
      if (consecutiveCorrect != null) 'consecutive_correct': consecutiveCorrect,
      if (easinessFactor != null) 'easiness_factor': easinessFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (userNote != null) 'user_note': userNote,
      if (isMastered != null) 'is_mastered': isMastered,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WrongQuestionBookTableCompanion copyWith({
    Value<String>? questionId,
    Value<String>? chapterId,
    Value<int>? errorCount,
    Value<int>? consecutiveCorrect,
    Value<double>? easinessFactor,
    Value<int>? intervalDays,
    Value<DateTime>? nextReviewAt,
    Value<String>? userNote,
    Value<bool>? isMastered,
    Value<int>? rowid,
  }) {
    return WrongQuestionBookTableCompanion(
      questionId: questionId ?? this.questionId,
      chapterId: chapterId ?? this.chapterId,
      errorCount: errorCount ?? this.errorCount,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      userNote: userNote ?? this.userNote,
      isMastered: isMastered ?? this.isMastered,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (consecutiveCorrect.present) {
      map['consecutive_correct'] = Variable<int>(consecutiveCorrect.value);
    }
    if (easinessFactor.present) {
      map['easiness_factor'] = Variable<double>(easinessFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (userNote.present) {
      map['user_note'] = Variable<String>(userNote.value);
    }
    if (isMastered.present) {
      map['is_mastered'] = Variable<bool>(isMastered.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WrongQuestionBookTableCompanion(')
          ..write('questionId: $questionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('errorCount: $errorCount, ')
          ..write('consecutiveCorrect: $consecutiveCorrect, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('userNote: $userNote, ')
          ..write('isMastered: $isMastered, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterMasteryTableTable extends ChapterMasteryTable
    with TableInfo<$ChapterMasteryTableTable, ChapterMastery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterMasteryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptScoreMeta = const VerificationMeta(
    'conceptScore',
  );
  @override
  late final GeneratedColumn<double> conceptScore = GeneratedColumn<double>(
    'concept_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _traceScoreMeta = const VerificationMeta(
    'traceScore',
  );
  @override
  late final GeneratedColumn<double> traceScore = GeneratedColumn<double>(
    'trace_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _codingScoreMeta = const VerificationMeta(
    'codingScore',
  );
  @override
  late final GeneratedColumn<double> codingScore = GeneratedColumn<double>(
    'coding_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _labCompletionRateMeta = const VerificationMeta(
    'labCompletionRate',
  );
  @override
  late final GeneratedColumn<double> labCompletionRate =
      GeneratedColumn<double>(
        'lab_completion_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _overallMasteryMeta = const VerificationMeta(
    'overallMastery',
  );
  @override
  late final GeneratedColumn<double> overallMastery = GeneratedColumn<double>(
    'overall_mastery',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    conceptScore,
    traceScore,
    codingScore,
    labCompletionRate,
    overallMastery,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_mastery_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterMastery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('concept_score')) {
      context.handle(
        _conceptScoreMeta,
        conceptScore.isAcceptableOrUnknown(
          data['concept_score']!,
          _conceptScoreMeta,
        ),
      );
    }
    if (data.containsKey('trace_score')) {
      context.handle(
        _traceScoreMeta,
        traceScore.isAcceptableOrUnknown(data['trace_score']!, _traceScoreMeta),
      );
    }
    if (data.containsKey('coding_score')) {
      context.handle(
        _codingScoreMeta,
        codingScore.isAcceptableOrUnknown(
          data['coding_score']!,
          _codingScoreMeta,
        ),
      );
    }
    if (data.containsKey('lab_completion_rate')) {
      context.handle(
        _labCompletionRateMeta,
        labCompletionRate.isAcceptableOrUnknown(
          data['lab_completion_rate']!,
          _labCompletionRateMeta,
        ),
      );
    }
    if (data.containsKey('overall_mastery')) {
      context.handle(
        _overallMasteryMeta,
        overallMastery.isAcceptableOrUnknown(
          data['overall_mastery']!,
          _overallMasteryMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ChapterMastery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterMastery(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      conceptScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concept_score'],
      )!,
      traceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trace_score'],
      )!,
      codingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coding_score'],
      )!,
      labCompletionRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lab_completion_rate'],
      )!,
      overallMastery: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_mastery'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChapterMasteryTableTable createAlias(String alias) {
    return $ChapterMasteryTableTable(attachedDatabase, alias);
  }
}

class ChapterMastery extends DataClass implements Insertable<ChapterMastery> {
  final String chapterId;
  final double conceptScore;
  final double traceScore;
  final double codingScore;
  final double labCompletionRate;
  final double overallMastery;
  final DateTime updatedAt;
  const ChapterMastery({
    required this.chapterId,
    required this.conceptScore,
    required this.traceScore,
    required this.codingScore,
    required this.labCompletionRate,
    required this.overallMastery,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['concept_score'] = Variable<double>(conceptScore);
    map['trace_score'] = Variable<double>(traceScore);
    map['coding_score'] = Variable<double>(codingScore);
    map['lab_completion_rate'] = Variable<double>(labCompletionRate);
    map['overall_mastery'] = Variable<double>(overallMastery);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChapterMasteryTableCompanion toCompanion(bool nullToAbsent) {
    return ChapterMasteryTableCompanion(
      chapterId: Value(chapterId),
      conceptScore: Value(conceptScore),
      traceScore: Value(traceScore),
      codingScore: Value(codingScore),
      labCompletionRate: Value(labCompletionRate),
      overallMastery: Value(overallMastery),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChapterMastery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterMastery(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      conceptScore: serializer.fromJson<double>(json['conceptScore']),
      traceScore: serializer.fromJson<double>(json['traceScore']),
      codingScore: serializer.fromJson<double>(json['codingScore']),
      labCompletionRate: serializer.fromJson<double>(json['labCompletionRate']),
      overallMastery: serializer.fromJson<double>(json['overallMastery']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'conceptScore': serializer.toJson<double>(conceptScore),
      'traceScore': serializer.toJson<double>(traceScore),
      'codingScore': serializer.toJson<double>(codingScore),
      'labCompletionRate': serializer.toJson<double>(labCompletionRate),
      'overallMastery': serializer.toJson<double>(overallMastery),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChapterMastery copyWith({
    String? chapterId,
    double? conceptScore,
    double? traceScore,
    double? codingScore,
    double? labCompletionRate,
    double? overallMastery,
    DateTime? updatedAt,
  }) => ChapterMastery(
    chapterId: chapterId ?? this.chapterId,
    conceptScore: conceptScore ?? this.conceptScore,
    traceScore: traceScore ?? this.traceScore,
    codingScore: codingScore ?? this.codingScore,
    labCompletionRate: labCompletionRate ?? this.labCompletionRate,
    overallMastery: overallMastery ?? this.overallMastery,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChapterMastery copyWithCompanion(ChapterMasteryTableCompanion data) {
    return ChapterMastery(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      conceptScore: data.conceptScore.present
          ? data.conceptScore.value
          : this.conceptScore,
      traceScore: data.traceScore.present
          ? data.traceScore.value
          : this.traceScore,
      codingScore: data.codingScore.present
          ? data.codingScore.value
          : this.codingScore,
      labCompletionRate: data.labCompletionRate.present
          ? data.labCompletionRate.value
          : this.labCompletionRate,
      overallMastery: data.overallMastery.present
          ? data.overallMastery.value
          : this.overallMastery,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterMastery(')
          ..write('chapterId: $chapterId, ')
          ..write('conceptScore: $conceptScore, ')
          ..write('traceScore: $traceScore, ')
          ..write('codingScore: $codingScore, ')
          ..write('labCompletionRate: $labCompletionRate, ')
          ..write('overallMastery: $overallMastery, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chapterId,
    conceptScore,
    traceScore,
    codingScore,
    labCompletionRate,
    overallMastery,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterMastery &&
          other.chapterId == this.chapterId &&
          other.conceptScore == this.conceptScore &&
          other.traceScore == this.traceScore &&
          other.codingScore == this.codingScore &&
          other.labCompletionRate == this.labCompletionRate &&
          other.overallMastery == this.overallMastery &&
          other.updatedAt == this.updatedAt);
}

class ChapterMasteryTableCompanion extends UpdateCompanion<ChapterMastery> {
  final Value<String> chapterId;
  final Value<double> conceptScore;
  final Value<double> traceScore;
  final Value<double> codingScore;
  final Value<double> labCompletionRate;
  final Value<double> overallMastery;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChapterMasteryTableCompanion({
    this.chapterId = const Value.absent(),
    this.conceptScore = const Value.absent(),
    this.traceScore = const Value.absent(),
    this.codingScore = const Value.absent(),
    this.labCompletionRate = const Value.absent(),
    this.overallMastery = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterMasteryTableCompanion.insert({
    required String chapterId,
    this.conceptScore = const Value.absent(),
    this.traceScore = const Value.absent(),
    this.codingScore = const Value.absent(),
    this.labCompletionRate = const Value.absent(),
    this.overallMastery = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       updatedAt = Value(updatedAt);
  static Insertable<ChapterMastery> custom({
    Expression<String>? chapterId,
    Expression<double>? conceptScore,
    Expression<double>? traceScore,
    Expression<double>? codingScore,
    Expression<double>? labCompletionRate,
    Expression<double>? overallMastery,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (conceptScore != null) 'concept_score': conceptScore,
      if (traceScore != null) 'trace_score': traceScore,
      if (codingScore != null) 'coding_score': codingScore,
      if (labCompletionRate != null) 'lab_completion_rate': labCompletionRate,
      if (overallMastery != null) 'overall_mastery': overallMastery,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterMasteryTableCompanion copyWith({
    Value<String>? chapterId,
    Value<double>? conceptScore,
    Value<double>? traceScore,
    Value<double>? codingScore,
    Value<double>? labCompletionRate,
    Value<double>? overallMastery,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChapterMasteryTableCompanion(
      chapterId: chapterId ?? this.chapterId,
      conceptScore: conceptScore ?? this.conceptScore,
      traceScore: traceScore ?? this.traceScore,
      codingScore: codingScore ?? this.codingScore,
      labCompletionRate: labCompletionRate ?? this.labCompletionRate,
      overallMastery: overallMastery ?? this.overallMastery,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (conceptScore.present) {
      map['concept_score'] = Variable<double>(conceptScore.value);
    }
    if (traceScore.present) {
      map['trace_score'] = Variable<double>(traceScore.value);
    }
    if (codingScore.present) {
      map['coding_score'] = Variable<double>(codingScore.value);
    }
    if (labCompletionRate.present) {
      map['lab_completion_rate'] = Variable<double>(labCompletionRate.value);
    }
    if (overallMastery.present) {
      map['overall_mastery'] = Variable<double>(overallMastery.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterMasteryTableCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('conceptScore: $conceptScore, ')
          ..write('traceScore: $traceScore, ')
          ..write('codingScore: $codingScore, ')
          ..write('labCompletionRate: $labCompletionRate, ')
          ..write('overallMastery: $overallMastery, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyStudyStatsTableTable extends DailyStudyStatsTable
    with TableInfo<$DailyStudyStatsTableTable, DailyStudyStats> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStudyStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studySecondsMeta = const VerificationMeta(
    'studySeconds',
  );
  @override
  late final GeneratedColumn<int> studySeconds = GeneratedColumn<int>(
    'study_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _studyMinutesMeta = const VerificationMeta(
    'studyMinutes',
  );
  @override
  late final GeneratedColumn<int> studyMinutes = GeneratedColumn<int>(
    'study_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _labsCompletedMeta = const VerificationMeta(
    'labsCompleted',
  );
  @override
  late final GeneratedColumn<int> labsCompleted = GeneratedColumn<int>(
    'labs_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _questionsSolvedMeta = const VerificationMeta(
    'questionsSolved',
  );
  @override
  late final GeneratedColumn<int> questionsSolved = GeneratedColumn<int>(
    'questions_solved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dateKey,
    studySeconds,
    studyMinutes,
    labsCompleted,
    questionsSolved,
    correctCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_study_stats_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStudyStats> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('study_seconds')) {
      context.handle(
        _studySecondsMeta,
        studySeconds.isAcceptableOrUnknown(
          data['study_seconds']!,
          _studySecondsMeta,
        ),
      );
    }
    if (data.containsKey('study_minutes')) {
      context.handle(
        _studyMinutesMeta,
        studyMinutes.isAcceptableOrUnknown(
          data['study_minutes']!,
          _studyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('labs_completed')) {
      context.handle(
        _labsCompletedMeta,
        labsCompleted.isAcceptableOrUnknown(
          data['labs_completed']!,
          _labsCompletedMeta,
        ),
      );
    }
    if (data.containsKey('questions_solved')) {
      context.handle(
        _questionsSolvedMeta,
        questionsSolved.isAcceptableOrUnknown(
          data['questions_solved']!,
          _questionsSolvedMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey};
  @override
  DailyStudyStats map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStudyStats(
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      studySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}study_seconds'],
      )!,
      studyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}study_minutes'],
      )!,
      labsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}labs_completed'],
      )!,
      questionsSolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}questions_solved'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
    );
  }

  @override
  $DailyStudyStatsTableTable createAlias(String alias) {
    return $DailyStudyStatsTableTable(attachedDatabase, alias);
  }
}

class DailyStudyStats extends DataClass implements Insertable<DailyStudyStats> {
  final String dateKey;
  final int studySeconds;
  final int studyMinutes;
  final int labsCompleted;
  final int questionsSolved;
  final int correctCount;
  const DailyStudyStats({
    required this.dateKey,
    required this.studySeconds,
    required this.studyMinutes,
    required this.labsCompleted,
    required this.questionsSolved,
    required this.correctCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    map['study_seconds'] = Variable<int>(studySeconds);
    map['study_minutes'] = Variable<int>(studyMinutes);
    map['labs_completed'] = Variable<int>(labsCompleted);
    map['questions_solved'] = Variable<int>(questionsSolved);
    map['correct_count'] = Variable<int>(correctCount);
    return map;
  }

  DailyStudyStatsTableCompanion toCompanion(bool nullToAbsent) {
    return DailyStudyStatsTableCompanion(
      dateKey: Value(dateKey),
      studySeconds: Value(studySeconds),
      studyMinutes: Value(studyMinutes),
      labsCompleted: Value(labsCompleted),
      questionsSolved: Value(questionsSolved),
      correctCount: Value(correctCount),
    );
  }

  factory DailyStudyStats.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStudyStats(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      studySeconds: serializer.fromJson<int>(json['studySeconds']),
      studyMinutes: serializer.fromJson<int>(json['studyMinutes']),
      labsCompleted: serializer.fromJson<int>(json['labsCompleted']),
      questionsSolved: serializer.fromJson<int>(json['questionsSolved']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'studySeconds': serializer.toJson<int>(studySeconds),
      'studyMinutes': serializer.toJson<int>(studyMinutes),
      'labsCompleted': serializer.toJson<int>(labsCompleted),
      'questionsSolved': serializer.toJson<int>(questionsSolved),
      'correctCount': serializer.toJson<int>(correctCount),
    };
  }

  DailyStudyStats copyWith({
    String? dateKey,
    int? studySeconds,
    int? studyMinutes,
    int? labsCompleted,
    int? questionsSolved,
    int? correctCount,
  }) => DailyStudyStats(
    dateKey: dateKey ?? this.dateKey,
    studySeconds: studySeconds ?? this.studySeconds,
    studyMinutes: studyMinutes ?? this.studyMinutes,
    labsCompleted: labsCompleted ?? this.labsCompleted,
    questionsSolved: questionsSolved ?? this.questionsSolved,
    correctCount: correctCount ?? this.correctCount,
  );
  DailyStudyStats copyWithCompanion(DailyStudyStatsTableCompanion data) {
    return DailyStudyStats(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      studySeconds: data.studySeconds.present
          ? data.studySeconds.value
          : this.studySeconds,
      studyMinutes: data.studyMinutes.present
          ? data.studyMinutes.value
          : this.studyMinutes,
      labsCompleted: data.labsCompleted.present
          ? data.labsCompleted.value
          : this.labsCompleted,
      questionsSolved: data.questionsSolved.present
          ? data.questionsSolved.value
          : this.questionsSolved,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStudyStats(')
          ..write('dateKey: $dateKey, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('studyMinutes: $studyMinutes, ')
          ..write('labsCompleted: $labsCompleted, ')
          ..write('questionsSolved: $questionsSolved, ')
          ..write('correctCount: $correctCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    dateKey,
    studySeconds,
    studyMinutes,
    labsCompleted,
    questionsSolved,
    correctCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStudyStats &&
          other.dateKey == this.dateKey &&
          other.studySeconds == this.studySeconds &&
          other.studyMinutes == this.studyMinutes &&
          other.labsCompleted == this.labsCompleted &&
          other.questionsSolved == this.questionsSolved &&
          other.correctCount == this.correctCount);
}

class DailyStudyStatsTableCompanion extends UpdateCompanion<DailyStudyStats> {
  final Value<String> dateKey;
  final Value<int> studySeconds;
  final Value<int> studyMinutes;
  final Value<int> labsCompleted;
  final Value<int> questionsSolved;
  final Value<int> correctCount;
  final Value<int> rowid;
  const DailyStudyStatsTableCompanion({
    this.dateKey = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.studyMinutes = const Value.absent(),
    this.labsCompleted = const Value.absent(),
    this.questionsSolved = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStudyStatsTableCompanion.insert({
    required String dateKey,
    this.studySeconds = const Value.absent(),
    this.studyMinutes = const Value.absent(),
    this.labsCompleted = const Value.absent(),
    this.questionsSolved = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dateKey = Value(dateKey);
  static Insertable<DailyStudyStats> custom({
    Expression<String>? dateKey,
    Expression<int>? studySeconds,
    Expression<int>? studyMinutes,
    Expression<int>? labsCompleted,
    Expression<int>? questionsSolved,
    Expression<int>? correctCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (studySeconds != null) 'study_seconds': studySeconds,
      if (studyMinutes != null) 'study_minutes': studyMinutes,
      if (labsCompleted != null) 'labs_completed': labsCompleted,
      if (questionsSolved != null) 'questions_solved': questionsSolved,
      if (correctCount != null) 'correct_count': correctCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStudyStatsTableCompanion copyWith({
    Value<String>? dateKey,
    Value<int>? studySeconds,
    Value<int>? studyMinutes,
    Value<int>? labsCompleted,
    Value<int>? questionsSolved,
    Value<int>? correctCount,
    Value<int>? rowid,
  }) {
    return DailyStudyStatsTableCompanion(
      dateKey: dateKey ?? this.dateKey,
      studySeconds: studySeconds ?? this.studySeconds,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      labsCompleted: labsCompleted ?? this.labsCompleted,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      correctCount: correctCount ?? this.correctCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (studySeconds.present) {
      map['study_seconds'] = Variable<int>(studySeconds.value);
    }
    if (studyMinutes.present) {
      map['study_minutes'] = Variable<int>(studyMinutes.value);
    }
    if (labsCompleted.present) {
      map['labs_completed'] = Variable<int>(labsCompleted.value);
    }
    if (questionsSolved.present) {
      map['questions_solved'] = Variable<int>(questionsSolved.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStudyStatsTableCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('studyMinutes: $studyMinutes, ')
          ..write('labsCompleted: $labsCompleted, ')
          ..write('questionsSolved: $questionsSolved, ')
          ..write('correctCount: $correctCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCustomDatasetsTableTable extends UserCustomDatasetsTable
    with TableInfo<$UserCustomDatasetsTableTable, UserCustomDataset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCustomDatasetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  payloadJson =
      GeneratedColumn<String>(
        'payload_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, dynamic>>(
        $UserCustomDatasetsTableTable.$converterpayloadJson,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    moduleId,
    name,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_custom_datasets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCustomDataset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCustomDataset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCustomDataset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      payloadJson: $UserCustomDatasetsTableTable.$converterpayloadJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payload_json'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserCustomDatasetsTableTable createAlias(String alias) {
    return $UserCustomDatasetsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterpayloadJson =
      const JsonMapConverter();
}

class UserCustomDataset extends DataClass
    implements Insertable<UserCustomDataset> {
  final int id;
  final String moduleId;
  final String name;
  final Map<String, dynamic> payloadJson;
  final DateTime createdAt;
  const UserCustomDataset({
    required this.id,
    required this.moduleId,
    required this.name,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['module_id'] = Variable<String>(moduleId);
    map['name'] = Variable<String>(name);
    {
      map['payload_json'] = Variable<String>(
        $UserCustomDatasetsTableTable.$converterpayloadJson.toSql(payloadJson),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserCustomDatasetsTableCompanion toCompanion(bool nullToAbsent) {
    return UserCustomDatasetsTableCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      name: Value(name),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory UserCustomDataset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCustomDataset(
      id: serializer.fromJson<int>(json['id']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      name: serializer.fromJson<String>(json['name']),
      payloadJson: serializer.fromJson<Map<String, dynamic>>(
        json['payloadJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleId': serializer.toJson<String>(moduleId),
      'name': serializer.toJson<String>(name),
      'payloadJson': serializer.toJson<Map<String, dynamic>>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserCustomDataset copyWith({
    int? id,
    String? moduleId,
    String? name,
    Map<String, dynamic>? payloadJson,
    DateTime? createdAt,
  }) => UserCustomDataset(
    id: id ?? this.id,
    moduleId: moduleId ?? this.moduleId,
    name: name ?? this.name,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  UserCustomDataset copyWithCompanion(UserCustomDatasetsTableCompanion data) {
    return UserCustomDataset(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      name: data.name.present ? data.name.value : this.name,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCustomDataset(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moduleId, name, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCustomDataset &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.name == this.name &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class UserCustomDatasetsTableCompanion
    extends UpdateCompanion<UserCustomDataset> {
  final Value<int> id;
  final Value<String> moduleId;
  final Value<String> name;
  final Value<Map<String, dynamic>> payloadJson;
  final Value<DateTime> createdAt;
  const UserCustomDatasetsTableCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.name = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserCustomDatasetsTableCompanion.insert({
    this.id = const Value.absent(),
    required String moduleId,
    required String name,
    required Map<String, dynamic> payloadJson,
    required DateTime createdAt,
  }) : moduleId = Value(moduleId),
       name = Value(name),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<UserCustomDataset> custom({
    Expression<int>? id,
    Expression<String>? moduleId,
    Expression<String>? name,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (name != null) 'name': name,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserCustomDatasetsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? moduleId,
    Value<String>? name,
    Value<Map<String, dynamic>>? payloadJson,
    Value<DateTime>? createdAt,
  }) {
    return UserCustomDatasetsTableCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      name: name ?? this.name,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(
        $UserCustomDatasetsTableTable.$converterpayloadJson.toSql(
          payloadJson.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCustomDatasetsTableCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CodeDraftsTableTable extends CodeDraftsTable
    with TableInfo<$CodeDraftsTableTable, CodeDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CodeDraftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeLangMeta = const VerificationMeta(
    'codeLang',
  );
  @override
  late final GeneratedColumn<String> codeLang = GeneratedColumn<String>(
    'code_lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceCodeMeta = const VerificationMeta(
    'sourceCode',
  );
  @override
  late final GeneratedColumn<String> sourceCode = GeneratedColumn<String>(
    'source_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPassRateMeta = const VerificationMeta(
    'lastPassRate',
  );
  @override
  late final GeneratedColumn<double> lastPassRate = GeneratedColumn<double>(
    'last_pass_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    codeLang,
    sourceCode,
    lastPassRate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'code_drafts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CodeDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('code_lang')) {
      context.handle(
        _codeLangMeta,
        codeLang.isAcceptableOrUnknown(data['code_lang']!, _codeLangMeta),
      );
    } else if (isInserting) {
      context.missing(_codeLangMeta);
    }
    if (data.containsKey('source_code')) {
      context.handle(
        _sourceCodeMeta,
        sourceCode.isAcceptableOrUnknown(data['source_code']!, _sourceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceCodeMeta);
    }
    if (data.containsKey('last_pass_rate')) {
      context.handle(
        _lastPassRateMeta,
        lastPassRate.isAcceptableOrUnknown(
          data['last_pass_rate']!,
          _lastPassRateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  CodeDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CodeDraft(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      codeLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_lang'],
      )!,
      sourceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_code'],
      )!,
      lastPassRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_pass_rate'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CodeDraftsTableTable createAlias(String alias) {
    return $CodeDraftsTableTable(attachedDatabase, alias);
  }
}

class CodeDraft extends DataClass implements Insertable<CodeDraft> {
  final String questionId;
  final String codeLang;
  final String sourceCode;
  final double lastPassRate;
  final DateTime updatedAt;
  const CodeDraft({
    required this.questionId,
    required this.codeLang,
    required this.sourceCode,
    required this.lastPassRate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['code_lang'] = Variable<String>(codeLang);
    map['source_code'] = Variable<String>(sourceCode);
    map['last_pass_rate'] = Variable<double>(lastPassRate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CodeDraftsTableCompanion toCompanion(bool nullToAbsent) {
    return CodeDraftsTableCompanion(
      questionId: Value(questionId),
      codeLang: Value(codeLang),
      sourceCode: Value(sourceCode),
      lastPassRate: Value(lastPassRate),
      updatedAt: Value(updatedAt),
    );
  }

  factory CodeDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CodeDraft(
      questionId: serializer.fromJson<String>(json['questionId']),
      codeLang: serializer.fromJson<String>(json['codeLang']),
      sourceCode: serializer.fromJson<String>(json['sourceCode']),
      lastPassRate: serializer.fromJson<double>(json['lastPassRate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'codeLang': serializer.toJson<String>(codeLang),
      'sourceCode': serializer.toJson<String>(sourceCode),
      'lastPassRate': serializer.toJson<double>(lastPassRate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CodeDraft copyWith({
    String? questionId,
    String? codeLang,
    String? sourceCode,
    double? lastPassRate,
    DateTime? updatedAt,
  }) => CodeDraft(
    questionId: questionId ?? this.questionId,
    codeLang: codeLang ?? this.codeLang,
    sourceCode: sourceCode ?? this.sourceCode,
    lastPassRate: lastPassRate ?? this.lastPassRate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CodeDraft copyWithCompanion(CodeDraftsTableCompanion data) {
    return CodeDraft(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      codeLang: data.codeLang.present ? data.codeLang.value : this.codeLang,
      sourceCode: data.sourceCode.present
          ? data.sourceCode.value
          : this.sourceCode,
      lastPassRate: data.lastPassRate.present
          ? data.lastPassRate.value
          : this.lastPassRate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CodeDraft(')
          ..write('questionId: $questionId, ')
          ..write('codeLang: $codeLang, ')
          ..write('sourceCode: $sourceCode, ')
          ..write('lastPassRate: $lastPassRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(questionId, codeLang, sourceCode, lastPassRate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CodeDraft &&
          other.questionId == this.questionId &&
          other.codeLang == this.codeLang &&
          other.sourceCode == this.sourceCode &&
          other.lastPassRate == this.lastPassRate &&
          other.updatedAt == this.updatedAt);
}

class CodeDraftsTableCompanion extends UpdateCompanion<CodeDraft> {
  final Value<String> questionId;
  final Value<String> codeLang;
  final Value<String> sourceCode;
  final Value<double> lastPassRate;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CodeDraftsTableCompanion({
    this.questionId = const Value.absent(),
    this.codeLang = const Value.absent(),
    this.sourceCode = const Value.absent(),
    this.lastPassRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CodeDraftsTableCompanion.insert({
    required String questionId,
    required String codeLang,
    required String sourceCode,
    this.lastPassRate = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       codeLang = Value(codeLang),
       sourceCode = Value(sourceCode),
       updatedAt = Value(updatedAt);
  static Insertable<CodeDraft> custom({
    Expression<String>? questionId,
    Expression<String>? codeLang,
    Expression<String>? sourceCode,
    Expression<double>? lastPassRate,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (codeLang != null) 'code_lang': codeLang,
      if (sourceCode != null) 'source_code': sourceCode,
      if (lastPassRate != null) 'last_pass_rate': lastPassRate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CodeDraftsTableCompanion copyWith({
    Value<String>? questionId,
    Value<String>? codeLang,
    Value<String>? sourceCode,
    Value<double>? lastPassRate,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CodeDraftsTableCompanion(
      questionId: questionId ?? this.questionId,
      codeLang: codeLang ?? this.codeLang,
      sourceCode: sourceCode ?? this.sourceCode,
      lastPassRate: lastPassRate ?? this.lastPassRate,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (codeLang.present) {
      map['code_lang'] = Variable<String>(codeLang.value);
    }
    if (sourceCode.present) {
      map['source_code'] = Variable<String>(sourceCode.value);
    }
    if (lastPassRate.present) {
      map['last_pass_rate'] = Variable<double>(lastPassRate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CodeDraftsTableCompanion(')
          ..write('questionId: $questionId, ')
          ..write('codeLang: $codeLang, ')
          ..write('sourceCode: $sourceCode, ')
          ..write('lastPassRate: $lastPassRate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTableTable extends AchievementsTable
    with TableInfo<$AchievementsTableTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressCurrentMeta = const VerificationMeta(
    'progressCurrent',
  );
  @override
  late final GeneratedColumn<int> progressCurrent = GeneratedColumn<int>(
    'progress_current',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressTargetMeta = const VerificationMeta(
    'progressTarget',
  );
  @override
  late final GeneratedColumn<int> progressTarget = GeneratedColumn<int>(
    'progress_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceMaskMeta = const VerificationMeta(
    'evidenceMask',
  );
  @override
  late final GeneratedColumn<int> evidenceMask = GeneratedColumn<int>(
    'evidence_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    achievementId,
    title,
    unlockedAt,
    progressCurrent,
    progressTarget,
    evidenceMask,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('progress_current')) {
      context.handle(
        _progressCurrentMeta,
        progressCurrent.isAcceptableOrUnknown(
          data['progress_current']!,
          _progressCurrentMeta,
        ),
      );
    }
    if (data.containsKey('progress_target')) {
      context.handle(
        _progressTargetMeta,
        progressTarget.isAcceptableOrUnknown(
          data['progress_target']!,
          _progressTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_progressTargetMeta);
    }
    if (data.containsKey('evidence_mask')) {
      context.handle(
        _evidenceMaskMeta,
        evidenceMask.isAcceptableOrUnknown(
          data['evidence_mask']!,
          _evidenceMaskMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      progressCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_current'],
      )!,
      progressTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_target'],
      )!,
      evidenceMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evidence_mask'],
      )!,
    );
  }

  @override
  $AchievementsTableTable createAlias(String alias) {
    return $AchievementsTableTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String achievementId;
  final String title;
  final DateTime? unlockedAt;
  final int progressCurrent;
  final int progressTarget;
  final int evidenceMask;
  const Achievement({
    required this.achievementId,
    required this.title,
    this.unlockedAt,
    required this.progressCurrent,
    required this.progressTarget,
    required this.evidenceMask,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['progress_current'] = Variable<int>(progressCurrent);
    map['progress_target'] = Variable<int>(progressTarget);
    map['evidence_mask'] = Variable<int>(evidenceMask);
    return map;
  }

  AchievementsTableCompanion toCompanion(bool nullToAbsent) {
    return AchievementsTableCompanion(
      achievementId: Value(achievementId),
      title: Value(title),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      progressCurrent: Value(progressCurrent),
      progressTarget: Value(progressTarget),
      evidenceMask: Value(evidenceMask),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      title: serializer.fromJson<String>(json['title']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      progressCurrent: serializer.fromJson<int>(json['progressCurrent']),
      progressTarget: serializer.fromJson<int>(json['progressTarget']),
      evidenceMask: serializer.fromJson<int>(json['evidenceMask']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'title': serializer.toJson<String>(title),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'progressCurrent': serializer.toJson<int>(progressCurrent),
      'progressTarget': serializer.toJson<int>(progressTarget),
      'evidenceMask': serializer.toJson<int>(evidenceMask),
    };
  }

  Achievement copyWith({
    String? achievementId,
    String? title,
    Value<DateTime?> unlockedAt = const Value.absent(),
    int? progressCurrent,
    int? progressTarget,
    int? evidenceMask,
  }) => Achievement(
    achievementId: achievementId ?? this.achievementId,
    title: title ?? this.title,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    progressCurrent: progressCurrent ?? this.progressCurrent,
    progressTarget: progressTarget ?? this.progressTarget,
    evidenceMask: evidenceMask ?? this.evidenceMask,
  );
  Achievement copyWithCompanion(AchievementsTableCompanion data) {
    return Achievement(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      title: data.title.present ? data.title.value : this.title,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      progressCurrent: data.progressCurrent.present
          ? data.progressCurrent.value
          : this.progressCurrent,
      progressTarget: data.progressTarget.present
          ? data.progressTarget.value
          : this.progressTarget,
      evidenceMask: data.evidenceMask.present
          ? data.evidenceMask.value
          : this.evidenceMask,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('achievementId: $achievementId, ')
          ..write('title: $title, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTarget: $progressTarget, ')
          ..write('evidenceMask: $evidenceMask')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    achievementId,
    title,
    unlockedAt,
    progressCurrent,
    progressTarget,
    evidenceMask,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.achievementId == this.achievementId &&
          other.title == this.title &&
          other.unlockedAt == this.unlockedAt &&
          other.progressCurrent == this.progressCurrent &&
          other.progressTarget == this.progressTarget &&
          other.evidenceMask == this.evidenceMask);
}

class AchievementsTableCompanion extends UpdateCompanion<Achievement> {
  final Value<String> achievementId;
  final Value<String> title;
  final Value<DateTime?> unlockedAt;
  final Value<int> progressCurrent;
  final Value<int> progressTarget;
  final Value<int> evidenceMask;
  final Value<int> rowid;
  const AchievementsTableCompanion({
    this.achievementId = const Value.absent(),
    this.title = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTarget = const Value.absent(),
    this.evidenceMask = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsTableCompanion.insert({
    required String achievementId,
    required String title,
    this.unlockedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    required int progressTarget,
    this.evidenceMask = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId),
       title = Value(title),
       progressTarget = Value(progressTarget);
  static Insertable<Achievement> custom({
    Expression<String>? achievementId,
    Expression<String>? title,
    Expression<DateTime>? unlockedAt,
    Expression<int>? progressCurrent,
    Expression<int>? progressTarget,
    Expression<int>? evidenceMask,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (title != null) 'title': title,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (progressCurrent != null) 'progress_current': progressCurrent,
      if (progressTarget != null) 'progress_target': progressTarget,
      if (evidenceMask != null) 'evidence_mask': evidenceMask,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsTableCompanion copyWith({
    Value<String>? achievementId,
    Value<String>? title,
    Value<DateTime?>? unlockedAt,
    Value<int>? progressCurrent,
    Value<int>? progressTarget,
    Value<int>? evidenceMask,
    Value<int>? rowid,
  }) {
    return AchievementsTableCompanion(
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTarget: progressTarget ?? this.progressTarget,
      evidenceMask: evidenceMask ?? this.evidenceMask,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (progressCurrent.present) {
      map['progress_current'] = Variable<int>(progressCurrent.value);
    }
    if (progressTarget.present) {
      map['progress_target'] = Variable<int>(progressTarget.value);
    }
    if (evidenceMask.present) {
      map['evidence_mask'] = Variable<int>(evidenceMask.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsTableCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('title: $title, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTarget: $progressTarget, ')
          ..write('evidenceMask: $evidenceMask, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LessonProgressTableTable lessonProgressTable =
      $LessonProgressTableTable(this);
  late final $QuizAttemptsTableTable quizAttemptsTable =
      $QuizAttemptsTableTable(this);
  late final $WrongQuestionBookTableTable wrongQuestionBookTable =
      $WrongQuestionBookTableTable(this);
  late final $ChapterMasteryTableTable chapterMasteryTable =
      $ChapterMasteryTableTable(this);
  late final $DailyStudyStatsTableTable dailyStudyStatsTable =
      $DailyStudyStatsTableTable(this);
  late final $UserCustomDatasetsTableTable userCustomDatasetsTable =
      $UserCustomDatasetsTableTable(this);
  late final $CodeDraftsTableTable codeDraftsTable = $CodeDraftsTableTable(
    this,
  );
  late final $AchievementsTableTable achievementsTable =
      $AchievementsTableTable(this);
  late final Index lessonChapter = Index(
    'lesson_chapter',
    'CREATE INDEX lesson_chapter ON lesson_progress_table (chapter_id)',
  );
  late final Index wrongDueMastered = Index(
    'wrong_due_mastered',
    'CREATE INDEX wrong_due_mastered ON wrong_question_book_table (next_review_at, is_mastered)',
  );
  late final Index datasetModuleName = Index(
    'dataset_module_name',
    'CREATE UNIQUE INDEX dataset_module_name ON user_custom_datasets_table (module_id, name)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lessonProgressTable,
    quizAttemptsTable,
    wrongQuestionBookTable,
    chapterMasteryTable,
    dailyStudyStatsTable,
    userCustomDatasetsTable,
    codeDraftsTable,
    achievementsTable,
    lessonChapter,
    wrongDueMastered,
    datasetModuleName,
  ];
}

typedef $$LessonProgressTableTableCreateCompanionBuilder =
    LessonProgressTableCompanion Function({
      required String moduleId,
      required String chapterId,
      Value<int> status,
      Value<bool> watchedFullTrace,
      Value<int> customRunCount,
      Value<int> timeSpentSeconds,
      required DateTime lastVisitedAt,
      Value<int> rowid,
    });
typedef $$LessonProgressTableTableUpdateCompanionBuilder =
    LessonProgressTableCompanion Function({
      Value<String> moduleId,
      Value<String> chapterId,
      Value<int> status,
      Value<bool> watchedFullTrace,
      Value<int> customRunCount,
      Value<int> timeSpentSeconds,
      Value<DateTime> lastVisitedAt,
      Value<int> rowid,
    });

class $$LessonProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTableTable> {
  $$LessonProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get watchedFullTrace => $composableBuilder(
    column: $table.watchedFullTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customRunCount => $composableBuilder(
    column: $table.customRunCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSpentSeconds => $composableBuilder(
    column: $table.timeSpentSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVisitedAt => $composableBuilder(
    column: $table.lastVisitedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTableTable> {
  $$LessonProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get watchedFullTrace => $composableBuilder(
    column: $table.watchedFullTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customRunCount => $composableBuilder(
    column: $table.customRunCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSpentSeconds => $composableBuilder(
    column: $table.timeSpentSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVisitedAt => $composableBuilder(
    column: $table.lastVisitedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTableTable> {
  $$LessonProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get watchedFullTrace => $composableBuilder(
    column: $table.watchedFullTrace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customRunCount => $composableBuilder(
    column: $table.customRunCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSpentSeconds => $composableBuilder(
    column: $table.timeSpentSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVisitedAt => $composableBuilder(
    column: $table.lastVisitedAt,
    builder: (column) => column,
  );
}

class $$LessonProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressTableTable,
          LessonProgress,
          $$LessonProgressTableTableFilterComposer,
          $$LessonProgressTableTableOrderingComposer,
          $$LessonProgressTableTableAnnotationComposer,
          $$LessonProgressTableTableCreateCompanionBuilder,
          $$LessonProgressTableTableUpdateCompanionBuilder,
          (
            LessonProgress,
            BaseReferences<
              _$AppDatabase,
              $LessonProgressTableTable,
              LessonProgress
            >,
          ),
          LessonProgress,
          PrefetchHooks Function()
        > {
  $$LessonProgressTableTableTableManager(
    _$AppDatabase db,
    $LessonProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LessonProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> moduleId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<bool> watchedFullTrace = const Value.absent(),
                Value<int> customRunCount = const Value.absent(),
                Value<int> timeSpentSeconds = const Value.absent(),
                Value<DateTime> lastVisitedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressTableCompanion(
                moduleId: moduleId,
                chapterId: chapterId,
                status: status,
                watchedFullTrace: watchedFullTrace,
                customRunCount: customRunCount,
                timeSpentSeconds: timeSpentSeconds,
                lastVisitedAt: lastVisitedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String moduleId,
                required String chapterId,
                Value<int> status = const Value.absent(),
                Value<bool> watchedFullTrace = const Value.absent(),
                Value<int> customRunCount = const Value.absent(),
                Value<int> timeSpentSeconds = const Value.absent(),
                required DateTime lastVisitedAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressTableCompanion.insert(
                moduleId: moduleId,
                chapterId: chapterId,
                status: status,
                watchedFullTrace: watchedFullTrace,
                customRunCount: customRunCount,
                timeSpentSeconds: timeSpentSeconds,
                lastVisitedAt: lastVisitedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LessonProgressTableTable, LessonProgress>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LessonProgressTableTable,
                    LessonProgress
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressTableTable,
      LessonProgress,
      $$LessonProgressTableTableFilterComposer,
      $$LessonProgressTableTableOrderingComposer,
      $$LessonProgressTableTableAnnotationComposer,
      $$LessonProgressTableTableCreateCompanionBuilder,
      $$LessonProgressTableTableUpdateCompanionBuilder,
      (
        LessonProgress,
        BaseReferences<
          _$AppDatabase,
          $LessonProgressTableTable,
          LessonProgress
        >,
      ),
      LessonProgress,
      PrefetchHooks Function()
    >;
typedef $$QuizAttemptsTableTableCreateCompanionBuilder =
    QuizAttemptsTableCompanion Function({
      Value<int> id,
      required String questionId,
      required String chapterId,
      required String questionType,
      required bool isCorrect,
      required int score,
      required Map<String, dynamic> userAnswerJson,
      required int durationMs,
      required DateTime attemptedAt,
    });
typedef $$QuizAttemptsTableTableUpdateCompanionBuilder =
    QuizAttemptsTableCompanion Function({
      Value<int> id,
      Value<String> questionId,
      Value<String> chapterId,
      Value<String> questionType,
      Value<bool> isCorrect,
      Value<int> score,
      Value<Map<String, dynamic>> userAnswerJson,
      Value<int> durationMs,
      Value<DateTime> attemptedAt,
    });

class $$QuizAttemptsTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTableTable> {
  $$QuizAttemptsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get userAnswerJson => $composableBuilder(
    column: $table.userAnswerJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuizAttemptsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTableTable> {
  $$QuizAttemptsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAnswerJson => $composableBuilder(
    column: $table.userAnswerJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizAttemptsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTableTable> {
  $$QuizAttemptsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get userAnswerJson => $composableBuilder(
    column: $table.userAnswerJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => column,
  );
}

class $$QuizAttemptsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizAttemptsTableTable,
          QuizAttempt,
          $$QuizAttemptsTableTableFilterComposer,
          $$QuizAttemptsTableTableOrderingComposer,
          $$QuizAttemptsTableTableAnnotationComposer,
          $$QuizAttemptsTableTableCreateCompanionBuilder,
          $$QuizAttemptsTableTableUpdateCompanionBuilder,
          (
            QuizAttempt,
            BaseReferences<_$AppDatabase, $QuizAttemptsTableTable, QuizAttempt>,
          ),
          QuizAttempt,
          PrefetchHooks Function()
        > {
  $$QuizAttemptsTableTableTableManager(
    _$AppDatabase db,
    $QuizAttemptsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizAttemptsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizAttemptsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizAttemptsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> questionType = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<Map<String, dynamic>> userAnswerJson =
                    const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> attemptedAt = const Value.absent(),
              }) => QuizAttemptsTableCompanion(
                id: id,
                questionId: questionId,
                chapterId: chapterId,
                questionType: questionType,
                isCorrect: isCorrect,
                score: score,
                userAnswerJson: userAnswerJson,
                durationMs: durationMs,
                attemptedAt: attemptedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String questionId,
                required String chapterId,
                required String questionType,
                required bool isCorrect,
                required int score,
                required Map<String, dynamic> userAnswerJson,
                required int durationMs,
                required DateTime attemptedAt,
              }) => QuizAttemptsTableCompanion.insert(
                id: id,
                questionId: questionId,
                chapterId: chapterId,
                questionType: questionType,
                isCorrect: isCorrect,
                score: score,
                userAnswerJson: userAnswerJson,
                durationMs: durationMs,
                attemptedAt: attemptedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuizAttemptsTableTable, QuizAttempt>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QuizAttemptsTableTable,
                    QuizAttempt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuizAttemptsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizAttemptsTableTable,
      QuizAttempt,
      $$QuizAttemptsTableTableFilterComposer,
      $$QuizAttemptsTableTableOrderingComposer,
      $$QuizAttemptsTableTableAnnotationComposer,
      $$QuizAttemptsTableTableCreateCompanionBuilder,
      $$QuizAttemptsTableTableUpdateCompanionBuilder,
      (
        QuizAttempt,
        BaseReferences<_$AppDatabase, $QuizAttemptsTableTable, QuizAttempt>,
      ),
      QuizAttempt,
      PrefetchHooks Function()
    >;
typedef $$WrongQuestionBookTableTableCreateCompanionBuilder =
    WrongQuestionBookTableCompanion Function({
      required String questionId,
      required String chapterId,
      Value<int> errorCount,
      Value<int> consecutiveCorrect,
      Value<double> easinessFactor,
      Value<int> intervalDays,
      required DateTime nextReviewAt,
      Value<String> userNote,
      Value<bool> isMastered,
      Value<int> rowid,
    });
typedef $$WrongQuestionBookTableTableUpdateCompanionBuilder =
    WrongQuestionBookTableCompanion Function({
      Value<String> questionId,
      Value<String> chapterId,
      Value<int> errorCount,
      Value<int> consecutiveCorrect,
      Value<double> easinessFactor,
      Value<int> intervalDays,
      Value<DateTime> nextReviewAt,
      Value<String> userNote,
      Value<bool> isMastered,
      Value<int> rowid,
    });

class $$WrongQuestionBookTableTableFilterComposer
    extends Composer<_$AppDatabase, $WrongQuestionBookTableTable> {
  $$WrongQuestionBookTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveCorrect => $composableBuilder(
    column: $table.consecutiveCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userNote => $composableBuilder(
    column: $table.userNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WrongQuestionBookTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WrongQuestionBookTableTable> {
  $$WrongQuestionBookTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveCorrect => $composableBuilder(
    column: $table.consecutiveCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userNote => $composableBuilder(
    column: $table.userNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WrongQuestionBookTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WrongQuestionBookTableTable> {
  $$WrongQuestionBookTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consecutiveCorrect => $composableBuilder(
    column: $table.consecutiveCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userNote =>
      $composableBuilder(column: $table.userNote, builder: (column) => column);

  GeneratedColumn<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => column,
  );
}

class $$WrongQuestionBookTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WrongQuestionBookTableTable,
          WrongQuestion,
          $$WrongQuestionBookTableTableFilterComposer,
          $$WrongQuestionBookTableTableOrderingComposer,
          $$WrongQuestionBookTableTableAnnotationComposer,
          $$WrongQuestionBookTableTableCreateCompanionBuilder,
          $$WrongQuestionBookTableTableUpdateCompanionBuilder,
          (
            WrongQuestion,
            BaseReferences<
              _$AppDatabase,
              $WrongQuestionBookTableTable,
              WrongQuestion
            >,
          ),
          WrongQuestion,
          PrefetchHooks Function()
        > {
  $$WrongQuestionBookTableTableTableManager(
    _$AppDatabase db,
    $WrongQuestionBookTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WrongQuestionBookTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WrongQuestionBookTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WrongQuestionBookTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<int> consecutiveCorrect = const Value.absent(),
                Value<double> easinessFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime> nextReviewAt = const Value.absent(),
                Value<String> userNote = const Value.absent(),
                Value<bool> isMastered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongQuestionBookTableCompanion(
                questionId: questionId,
                chapterId: chapterId,
                errorCount: errorCount,
                consecutiveCorrect: consecutiveCorrect,
                easinessFactor: easinessFactor,
                intervalDays: intervalDays,
                nextReviewAt: nextReviewAt,
                userNote: userNote,
                isMastered: isMastered,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required String chapterId,
                Value<int> errorCount = const Value.absent(),
                Value<int> consecutiveCorrect = const Value.absent(),
                Value<double> easinessFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                required DateTime nextReviewAt,
                Value<String> userNote = const Value.absent(),
                Value<bool> isMastered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongQuestionBookTableCompanion.insert(
                questionId: questionId,
                chapterId: chapterId,
                errorCount: errorCount,
                consecutiveCorrect: consecutiveCorrect,
                easinessFactor: easinessFactor,
                intervalDays: intervalDays,
                nextReviewAt: nextReviewAt,
                userNote: userNote,
                isMastered: isMastered,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WrongQuestionBookTableTable, WrongQuestion>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $WrongQuestionBookTableTable,
                    WrongQuestion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WrongQuestionBookTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WrongQuestionBookTableTable,
      WrongQuestion,
      $$WrongQuestionBookTableTableFilterComposer,
      $$WrongQuestionBookTableTableOrderingComposer,
      $$WrongQuestionBookTableTableAnnotationComposer,
      $$WrongQuestionBookTableTableCreateCompanionBuilder,
      $$WrongQuestionBookTableTableUpdateCompanionBuilder,
      (
        WrongQuestion,
        BaseReferences<
          _$AppDatabase,
          $WrongQuestionBookTableTable,
          WrongQuestion
        >,
      ),
      WrongQuestion,
      PrefetchHooks Function()
    >;
typedef $$ChapterMasteryTableTableCreateCompanionBuilder =
    ChapterMasteryTableCompanion Function({
      required String chapterId,
      Value<double> conceptScore,
      Value<double> traceScore,
      Value<double> codingScore,
      Value<double> labCompletionRate,
      Value<double> overallMastery,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChapterMasteryTableTableUpdateCompanionBuilder =
    ChapterMasteryTableCompanion Function({
      Value<String> chapterId,
      Value<double> conceptScore,
      Value<double> traceScore,
      Value<double> codingScore,
      Value<double> labCompletionRate,
      Value<double> overallMastery,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChapterMasteryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterMasteryTableTable> {
  $$ChapterMasteryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get conceptScore => $composableBuilder(
    column: $table.conceptScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get traceScore => $composableBuilder(
    column: $table.traceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get codingScore => $composableBuilder(
    column: $table.codingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get labCompletionRate => $composableBuilder(
    column: $table.labCompletionRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallMastery => $composableBuilder(
    column: $table.overallMastery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterMasteryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterMasteryTableTable> {
  $$ChapterMasteryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get conceptScore => $composableBuilder(
    column: $table.conceptScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get traceScore => $composableBuilder(
    column: $table.traceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get codingScore => $composableBuilder(
    column: $table.codingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get labCompletionRate => $composableBuilder(
    column: $table.labCompletionRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallMastery => $composableBuilder(
    column: $table.overallMastery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterMasteryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterMasteryTableTable> {
  $$ChapterMasteryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<double> get conceptScore => $composableBuilder(
    column: $table.conceptScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get traceScore => $composableBuilder(
    column: $table.traceScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get codingScore => $composableBuilder(
    column: $table.codingScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get labCompletionRate => $composableBuilder(
    column: $table.labCompletionRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallMastery => $composableBuilder(
    column: $table.overallMastery,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChapterMasteryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterMasteryTableTable,
          ChapterMastery,
          $$ChapterMasteryTableTableFilterComposer,
          $$ChapterMasteryTableTableOrderingComposer,
          $$ChapterMasteryTableTableAnnotationComposer,
          $$ChapterMasteryTableTableCreateCompanionBuilder,
          $$ChapterMasteryTableTableUpdateCompanionBuilder,
          (
            ChapterMastery,
            BaseReferences<
              _$AppDatabase,
              $ChapterMasteryTableTable,
              ChapterMastery
            >,
          ),
          ChapterMastery,
          PrefetchHooks Function()
        > {
  $$ChapterMasteryTableTableTableManager(
    _$AppDatabase db,
    $ChapterMasteryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterMasteryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterMasteryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterMasteryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<double> conceptScore = const Value.absent(),
                Value<double> traceScore = const Value.absent(),
                Value<double> codingScore = const Value.absent(),
                Value<double> labCompletionRate = const Value.absent(),
                Value<double> overallMastery = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterMasteryTableCompanion(
                chapterId: chapterId,
                conceptScore: conceptScore,
                traceScore: traceScore,
                codingScore: codingScore,
                labCompletionRate: labCompletionRate,
                overallMastery: overallMastery,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                Value<double> conceptScore = const Value.absent(),
                Value<double> traceScore = const Value.absent(),
                Value<double> codingScore = const Value.absent(),
                Value<double> labCompletionRate = const Value.absent(),
                Value<double> overallMastery = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChapterMasteryTableCompanion.insert(
                chapterId: chapterId,
                conceptScore: conceptScore,
                traceScore: traceScore,
                codingScore: codingScore,
                labCompletionRate: labCompletionRate,
                overallMastery: overallMastery,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChapterMasteryTableTable, ChapterMastery>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChapterMasteryTableTable,
                    ChapterMastery
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterMasteryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterMasteryTableTable,
      ChapterMastery,
      $$ChapterMasteryTableTableFilterComposer,
      $$ChapterMasteryTableTableOrderingComposer,
      $$ChapterMasteryTableTableAnnotationComposer,
      $$ChapterMasteryTableTableCreateCompanionBuilder,
      $$ChapterMasteryTableTableUpdateCompanionBuilder,
      (
        ChapterMastery,
        BaseReferences<
          _$AppDatabase,
          $ChapterMasteryTableTable,
          ChapterMastery
        >,
      ),
      ChapterMastery,
      PrefetchHooks Function()
    >;
typedef $$DailyStudyStatsTableTableCreateCompanionBuilder =
    DailyStudyStatsTableCompanion Function({
      required String dateKey,
      Value<int> studySeconds,
      Value<int> studyMinutes,
      Value<int> labsCompleted,
      Value<int> questionsSolved,
      Value<int> correctCount,
      Value<int> rowid,
    });
typedef $$DailyStudyStatsTableTableUpdateCompanionBuilder =
    DailyStudyStatsTableCompanion Function({
      Value<String> dateKey,
      Value<int> studySeconds,
      Value<int> studyMinutes,
      Value<int> labsCompleted,
      Value<int> questionsSolved,
      Value<int> correctCount,
      Value<int> rowid,
    });

class $$DailyStudyStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStudyStatsTableTable> {
  $$DailyStudyStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studyMinutes => $composableBuilder(
    column: $table.studyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labsCompleted => $composableBuilder(
    column: $table.labsCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionsSolved => $composableBuilder(
    column: $table.questionsSolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStudyStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStudyStatsTableTable> {
  $$DailyStudyStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studyMinutes => $composableBuilder(
    column: $table.studyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labsCompleted => $composableBuilder(
    column: $table.labsCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionsSolved => $composableBuilder(
    column: $table.questionsSolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStudyStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStudyStatsTableTable> {
  $$DailyStudyStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get studyMinutes => $composableBuilder(
    column: $table.studyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get labsCompleted => $composableBuilder(
    column: $table.labsCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionsSolved => $composableBuilder(
    column: $table.questionsSolved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );
}

class $$DailyStudyStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStudyStatsTableTable,
          DailyStudyStats,
          $$DailyStudyStatsTableTableFilterComposer,
          $$DailyStudyStatsTableTableOrderingComposer,
          $$DailyStudyStatsTableTableAnnotationComposer,
          $$DailyStudyStatsTableTableCreateCompanionBuilder,
          $$DailyStudyStatsTableTableUpdateCompanionBuilder,
          (
            DailyStudyStats,
            BaseReferences<
              _$AppDatabase,
              $DailyStudyStatsTableTable,
              DailyStudyStats
            >,
          ),
          DailyStudyStats,
          PrefetchHooks Function()
        > {
  $$DailyStudyStatsTableTableTableManager(
    _$AppDatabase db,
    $DailyStudyStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStudyStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStudyStatsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyStudyStatsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> dateKey = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<int> studyMinutes = const Value.absent(),
                Value<int> labsCompleted = const Value.absent(),
                Value<int> questionsSolved = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStudyStatsTableCompanion(
                dateKey: dateKey,
                studySeconds: studySeconds,
                studyMinutes: studyMinutes,
                labsCompleted: labsCompleted,
                questionsSolved: questionsSolved,
                correctCount: correctCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dateKey,
                Value<int> studySeconds = const Value.absent(),
                Value<int> studyMinutes = const Value.absent(),
                Value<int> labsCompleted = const Value.absent(),
                Value<int> questionsSolved = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStudyStatsTableCompanion.insert(
                dateKey: dateKey,
                studySeconds: studySeconds,
                studyMinutes: studyMinutes,
                labsCompleted: labsCompleted,
                questionsSolved: questionsSolved,
                correctCount: correctCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyStudyStatsTableTable, DailyStudyStats>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyStudyStatsTableTable,
                    DailyStudyStats
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStudyStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStudyStatsTableTable,
      DailyStudyStats,
      $$DailyStudyStatsTableTableFilterComposer,
      $$DailyStudyStatsTableTableOrderingComposer,
      $$DailyStudyStatsTableTableAnnotationComposer,
      $$DailyStudyStatsTableTableCreateCompanionBuilder,
      $$DailyStudyStatsTableTableUpdateCompanionBuilder,
      (
        DailyStudyStats,
        BaseReferences<
          _$AppDatabase,
          $DailyStudyStatsTableTable,
          DailyStudyStats
        >,
      ),
      DailyStudyStats,
      PrefetchHooks Function()
    >;
typedef $$UserCustomDatasetsTableTableCreateCompanionBuilder =
    UserCustomDatasetsTableCompanion Function({
      Value<int> id,
      required String moduleId,
      required String name,
      required Map<String, dynamic> payloadJson,
      required DateTime createdAt,
    });
typedef $$UserCustomDatasetsTableTableUpdateCompanionBuilder =
    UserCustomDatasetsTableCompanion Function({
      Value<int> id,
      Value<String> moduleId,
      Value<String> name,
      Value<Map<String, dynamic>> payloadJson,
      Value<DateTime> createdAt,
    });

class $$UserCustomDatasetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserCustomDatasetsTableTable> {
  $$UserCustomDatasetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCustomDatasetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCustomDatasetsTableTable> {
  $$UserCustomDatasetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCustomDatasetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCustomDatasetsTableTable> {
  $$UserCustomDatasetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserCustomDatasetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCustomDatasetsTableTable,
          UserCustomDataset,
          $$UserCustomDatasetsTableTableFilterComposer,
          $$UserCustomDatasetsTableTableOrderingComposer,
          $$UserCustomDatasetsTableTableAnnotationComposer,
          $$UserCustomDatasetsTableTableCreateCompanionBuilder,
          $$UserCustomDatasetsTableTableUpdateCompanionBuilder,
          (
            UserCustomDataset,
            BaseReferences<
              _$AppDatabase,
              $UserCustomDatasetsTableTable,
              UserCustomDataset
            >,
          ),
          UserCustomDataset,
          PrefetchHooks Function()
        > {
  $$UserCustomDatasetsTableTableTableManager(
    _$AppDatabase db,
    $UserCustomDatasetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCustomDatasetsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserCustomDatasetsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserCustomDatasetsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Map<String, dynamic>> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserCustomDatasetsTableCompanion(
                id: id,
                moduleId: moduleId,
                name: name,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String moduleId,
                required String name,
                required Map<String, dynamic> payloadJson,
                required DateTime createdAt,
              }) => UserCustomDatasetsTableCompanion.insert(
                id: id,
                moduleId: moduleId,
                name: name,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserCustomDatasetsTableTable, UserCustomDataset>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $UserCustomDatasetsTableTable,
                    UserCustomDataset
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCustomDatasetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCustomDatasetsTableTable,
      UserCustomDataset,
      $$UserCustomDatasetsTableTableFilterComposer,
      $$UserCustomDatasetsTableTableOrderingComposer,
      $$UserCustomDatasetsTableTableAnnotationComposer,
      $$UserCustomDatasetsTableTableCreateCompanionBuilder,
      $$UserCustomDatasetsTableTableUpdateCompanionBuilder,
      (
        UserCustomDataset,
        BaseReferences<
          _$AppDatabase,
          $UserCustomDatasetsTableTable,
          UserCustomDataset
        >,
      ),
      UserCustomDataset,
      PrefetchHooks Function()
    >;
typedef $$CodeDraftsTableTableCreateCompanionBuilder =
    CodeDraftsTableCompanion Function({
      required String questionId,
      required String codeLang,
      required String sourceCode,
      Value<double> lastPassRate,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CodeDraftsTableTableUpdateCompanionBuilder =
    CodeDraftsTableCompanion Function({
      Value<String> questionId,
      Value<String> codeLang,
      Value<String> sourceCode,
      Value<double> lastPassRate,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CodeDraftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CodeDraftsTableTable> {
  $$CodeDraftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeLang => $composableBuilder(
    column: $table.codeLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastPassRate => $composableBuilder(
    column: $table.lastPassRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CodeDraftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CodeDraftsTableTable> {
  $$CodeDraftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeLang => $composableBuilder(
    column: $table.codeLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastPassRate => $composableBuilder(
    column: $table.lastPassRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CodeDraftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CodeDraftsTableTable> {
  $$CodeDraftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codeLang =>
      $composableBuilder(column: $table.codeLang, builder: (column) => column);

  GeneratedColumn<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastPassRate => $composableBuilder(
    column: $table.lastPassRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CodeDraftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CodeDraftsTableTable,
          CodeDraft,
          $$CodeDraftsTableTableFilterComposer,
          $$CodeDraftsTableTableOrderingComposer,
          $$CodeDraftsTableTableAnnotationComposer,
          $$CodeDraftsTableTableCreateCompanionBuilder,
          $$CodeDraftsTableTableUpdateCompanionBuilder,
          (
            CodeDraft,
            BaseReferences<_$AppDatabase, $CodeDraftsTableTable, CodeDraft>,
          ),
          CodeDraft,
          PrefetchHooks Function()
        > {
  $$CodeDraftsTableTableTableManager(
    _$AppDatabase db,
    $CodeDraftsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CodeDraftsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CodeDraftsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CodeDraftsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<String> codeLang = const Value.absent(),
                Value<String> sourceCode = const Value.absent(),
                Value<double> lastPassRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CodeDraftsTableCompanion(
                questionId: questionId,
                codeLang: codeLang,
                sourceCode: sourceCode,
                lastPassRate: lastPassRate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required String codeLang,
                required String sourceCode,
                Value<double> lastPassRate = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CodeDraftsTableCompanion.insert(
                questionId: questionId,
                codeLang: codeLang,
                sourceCode: sourceCode,
                lastPassRate: lastPassRate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CodeDraftsTableTable, CodeDraft>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CodeDraftsTableTable,
                    CodeDraft
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CodeDraftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CodeDraftsTableTable,
      CodeDraft,
      $$CodeDraftsTableTableFilterComposer,
      $$CodeDraftsTableTableOrderingComposer,
      $$CodeDraftsTableTableAnnotationComposer,
      $$CodeDraftsTableTableCreateCompanionBuilder,
      $$CodeDraftsTableTableUpdateCompanionBuilder,
      (
        CodeDraft,
        BaseReferences<_$AppDatabase, $CodeDraftsTableTable, CodeDraft>,
      ),
      CodeDraft,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableTableCreateCompanionBuilder =
    AchievementsTableCompanion Function({
      required String achievementId,
      required String title,
      Value<DateTime?> unlockedAt,
      Value<int> progressCurrent,
      required int progressTarget,
      Value<int> evidenceMask,
      Value<int> rowid,
    });
typedef $$AchievementsTableTableUpdateCompanionBuilder =
    AchievementsTableCompanion Function({
      Value<String> achievementId,
      Value<String> title,
      Value<DateTime?> unlockedAt,
      Value<int> progressCurrent,
      Value<int> progressTarget,
      Value<int> evidenceMask,
      Value<int> rowid,
    });

class $$AchievementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressTarget => $composableBuilder(
    column: $table.progressTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get evidenceMask => $composableBuilder(
    column: $table.evidenceMask,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressTarget => $composableBuilder(
    column: $table.progressTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get evidenceMask => $composableBuilder(
    column: $table.evidenceMask,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressTarget => $composableBuilder(
    column: $table.progressTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get evidenceMask => $composableBuilder(
    column: $table.evidenceMask,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTableTable,
          Achievement,
          $$AchievementsTableTableFilterComposer,
          $$AchievementsTableTableOrderingComposer,
          $$AchievementsTableTableAnnotationComposer,
          $$AchievementsTableTableCreateCompanionBuilder,
          $$AchievementsTableTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTableTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableTableManager(
    _$AppDatabase db,
    $AchievementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> progressCurrent = const Value.absent(),
                Value<int> progressTarget = const Value.absent(),
                Value<int> evidenceMask = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsTableCompanion(
                achievementId: achievementId,
                title: title,
                unlockedAt: unlockedAt,
                progressCurrent: progressCurrent,
                progressTarget: progressTarget,
                evidenceMask: evidenceMask,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                required String title,
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> progressCurrent = const Value.absent(),
                required int progressTarget,
                Value<int> evidenceMask = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsTableCompanion.insert(
                achievementId: achievementId,
                title: title,
                unlockedAt: unlockedAt,
                progressCurrent: progressCurrent,
                progressTarget: progressTarget,
                evidenceMask: evidenceMask,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTableTable, Achievement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AchievementsTableTable,
                    Achievement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTableTable,
      Achievement,
      $$AchievementsTableTableFilterComposer,
      $$AchievementsTableTableOrderingComposer,
      $$AchievementsTableTableAnnotationComposer,
      $$AchievementsTableTableCreateCompanionBuilder,
      $$AchievementsTableTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTableTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LessonProgressTableTableTableManager get lessonProgressTable =>
      $$LessonProgressTableTableTableManager(_db, _db.lessonProgressTable);
  $$QuizAttemptsTableTableTableManager get quizAttemptsTable =>
      $$QuizAttemptsTableTableTableManager(_db, _db.quizAttemptsTable);
  $$WrongQuestionBookTableTableTableManager get wrongQuestionBookTable =>
      $$WrongQuestionBookTableTableTableManager(
        _db,
        _db.wrongQuestionBookTable,
      );
  $$ChapterMasteryTableTableTableManager get chapterMasteryTable =>
      $$ChapterMasteryTableTableTableManager(_db, _db.chapterMasteryTable);
  $$DailyStudyStatsTableTableTableManager get dailyStudyStatsTable =>
      $$DailyStudyStatsTableTableTableManager(_db, _db.dailyStudyStatsTable);
  $$UserCustomDatasetsTableTableTableManager get userCustomDatasetsTable =>
      $$UserCustomDatasetsTableTableTableManager(
        _db,
        _db.userCustomDatasetsTable,
      );
  $$CodeDraftsTableTableTableManager get codeDraftsTable =>
      $$CodeDraftsTableTableTableManager(_db, _db.codeDraftsTable);
  $$AchievementsTableTableTableManager get achievementsTable =>
      $$AchievementsTableTableTableManager(_db, _db.achievementsTable);
}
