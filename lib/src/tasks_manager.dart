import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/src/task_widget.dart';

import 'tracker.dart';

class TasksManager extends ChangeNotifier {
  static const String prefKeyTaskNames = "tasknames";

  static TasksManager? instance;

  TasksManager() {
    init();
    TasksManager.instance = this;
  }

  Future<void> init() async {
    List<String> taskNames =
        preferences.getStringList(prefKeyTaskNames) ?? <String>[];
    for (final taskName in taskNames) {
      var tm = TaskModel(taskName);
      int? startTimeMS = preferences.getInt("task_${taskName}_startTime");
      if (startTimeMS != null) {
        // tm.startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMS);
        tm._activate(DateTime.fromMillisecondsSinceEpoch(startTimeMS));
      } else {
        tm.startTime = null;
      }
      int? durationSec = preferences.getInt("task_${taskName}_duration");
      if (durationSec != null) {
        tm.duration = Duration(seconds: durationSec);
      } else {
        tm.duration = const Duration();
      }
      tasks.add(tm);
    }
    notifyListeners();
  }

  Future<void> store() async {
    List<String> taskNames = <String>[];
    for (var element in tasks) {
      taskNames.add(element.name);
    }
    await preferences.setStringList(prefKeyTaskNames, taskNames);
  }

  Future<void> storeTasks() async {
    List<String> taskNames = <String>[];
    for (var element in tasks) {
      taskNames.add(element.name);
      if (element.startTime != null) {
        await preferences.setInt("task_${element.name}_startTime",
            element.startTime!.millisecondsSinceEpoch);
      } else {
        await preferences.remove("task_${element.name}_startTime");
      }
      await preferences.setInt(
          "task_${element.name}_duration", element.duration.inSeconds);
    }
    await preferences.setStringList(prefKeyTaskNames, taskNames);
  }

  static final List<TaskModel> tasks = List<TaskModel>.empty(growable: true);

  addTask(String name) {
    if (name.isEmpty) name = "Unnamed Task";
    tasks.add(TaskModel(name));
    storeTasks();
    notifyListeners();
  }

  void deleteTask(TaskModel model) {
    tasks.remove(model);
    preferences.remove("task_${model.name}_startTime");
    preferences.remove("task_${model.name}_duration");
    storeTasks();
    notifyListeners();
  }

  List<TaskWidget> widgets() {
    return List<TaskWidget>.generate(
        tasks.length, (index) => TaskWidget(tm: tasks.elementAt(index)),
        growable: true);
  }
}

class TaskModel extends ChangeNotifier {
  TaskModel(this.name);

  String name = "unnamed";

  /// Start time of current activity. Null if not active.
  DateTime? startTime;
  void _setStartTime(DateTime? newValue) {
    startTime = newValue;
    if (startTime != null) {
      preferences.setInt(
          "task_${name}_startTime", startTime!.millisecondsSinceEpoch);
    } else {
      preferences.remove("task_${name}_startTime");
    }
  }

  /// Accumulated duration of finished active times.
  Duration duration = const Duration();
  void _setDuration(Duration newValue) {
    duration = newValue;
    preferences.setInt("task_${name}_duration", duration.inSeconds);
  }

  bool active = false;
  Timer? timer;

  toggleActive() {
    if (Hive.box('tracker').get('totalTrackMode', defaultValue: false)) {
      for (var task in TasksManager.tasks) {
        if (task.active) {
          task._deactivate();
        }
      }
      _activate(DateTime.now());
    } else {
      if (active) {
        _deactivate();
      } else {
        _activate(DateTime.now());
      }
    }
    notifyListeners();
  }

  void _deactivate() {
    active = false;
    timer?.cancel();
    _setDuration(duration +
        (startTime != null
            ? DateTime.now().difference(startTime!)
            : Duration.zero));
    _setStartTime(null);
    preferences.remove("task_${name}_startTime");
    notifyListeners();
  }

  void _activate(DateTime time) {
    _setStartTime(time);
    active = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();
    });
  }

  String getTimeString() {
    Duration currentDuration = startTime != null
        ? duration + DateTime.now().difference(startTime!)
        : duration;
    final int hours = currentDuration.inHours;
    final int minutes = currentDuration.inMinutes.remainder(60);
    final int seconds = currentDuration.inSeconds.remainder(60);
    return "${hours}h:${minutes}m:${seconds}s";
  }

  void reset() {
    _setDuration(const Duration());
    _setStartTime(null);
    if (active) toggleActive();
    notifyListeners();
  }
}
