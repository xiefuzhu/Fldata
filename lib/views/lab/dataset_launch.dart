import 'package:flutter/widgets.dart';

class DatasetLaunch {
  const DatasetLaunch(this.moduleId, this.input, {required this.custom});
  final String moduleId;
  final Object input;
  final bool custom;
}

class DatasetScope extends InheritedWidget {
  const DatasetScope({super.key, required this.launch, required super.child});
  final DatasetLaunch? launch;
  static DatasetLaunch? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DatasetScope>()?.launch;
  @override
  bool updateShouldNotify(DatasetScope oldWidget) => launch != oldWidget.launch;
}
