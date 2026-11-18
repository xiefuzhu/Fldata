import '../database/app_database.dart';

/// UTC midnight represents a civil date here, so stepping one day survives DST.
DateTime studyDay(DateTime local) =>
    DateTime.utc(local.year, local.month, local.day);
String dayKey(DateTime day) => day.toIso8601String().substring(0, 10);
bool studied(DailyStudyStats? row) =>
    row != null &&
    (row.studySeconds > 0 ||
        row.studyMinutes > 0 ||
        row.questionsSolved > 0 ||
        row.labsCompleted > 0);

int currentStudyStreak(Map<String, DailyStudyStats> rows, DateTime today) {
  var date = studyDay(today);
  const day = Duration(days: 1);
  if (!studied(rows[dayKey(date)])) date = date.subtract(day);
  var count = 0;
  while (studied(rows[dayKey(date)])) {
    count++;
    date = date.subtract(day);
  }
  return count;
}
