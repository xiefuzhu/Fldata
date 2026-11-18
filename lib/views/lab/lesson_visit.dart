import 'dart:async';
import 'package:flutter/widgets.dart';
import 'dataset_launch.dart';
import '../../database/repositories/progress_repository.dart';
import '../../enum/ds_enums.dart';

/// One foreground visit; writes are serialized and only successful deltas count.
class LessonVisit {
  LessonVisit(
    this.repository, {
    required this.moduleId,
    required this.chapterId,
  });
  final ProgressRepository repository;
  final String moduleId;
  final ChapterId chapterId;
  final clock = Stopwatch();
  int creditedSeconds = 0;
  int _pendingCustomRuns = 0;
  Future<void> _tail = Future.value();
  Future<void> save({bool completed = false, bool watchedFullTrace = false}) {
    final write = _tail.then((_) async {
      final total = clock.elapsed.inSeconds;
      final runs = _pendingCustomRuns;
      await repository.recordVisit(
        additionalCustomRuns: runs,
        moduleId: moduleId,
        chapterId: chapterId,
        elapsedSeconds: total - creditedSeconds,
        completed: completed,
        watchedFullTrace: watchedFullTrace,
      );
      _pendingCustomRuns -= runs;
      creditedSeconds = total;
    });
    // Keep later saves usable after a failed write; the caller still sees error.
    _tail = write.catchError((Object _) {});
    return write;
  }
}

mixin CustomLessonInput<T> {
  LessonVisit get visit;
  void changeInput(T next);
  Future<void> saveProgress({bool completed = false, bool watched = false});

  T initialDataset(BuildContext context, T fallback) {
    final launch = DatasetScope.of(context);
    if (launch == null ||
        launch.moduleId != visit.moduleId ||
        launch.input is! T) {
      return fallback;
    }
    if (launch.custom) visit._pendingCustomRuns++;
    return launch.input as T;
  }

  void runCustomInput(T next) {
    changeInput(next);
    visit._pendingCustomRuns++;
    unawaited(saveProgress());
  }
}
