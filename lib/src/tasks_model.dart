import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/main.dart';

class TasksModel extends ChangeNotifier {
  static const String prefKeyTaskNames = "tasknames";

  TasksModel() {
    init();
  }

  Future<void> init() async {
    // TODO: show some spinner while we load the prefs to avoid a short view on a blank page at start
    List<String> taskNames =
        preferences.getStringList(prefKeyTaskNames) ?? <String>[];
    for (final taskName in taskNames) {
      var tm = TaskModel(taskName);
      tm.elapsedSeconds = preferences.getInt("task_${taskName}_secs") ?? 0;
      tm.elapsedMinutes = preferences.getInt("task_${taskName}_mins") ?? 0;
      tm.elapsedHours = preferences.getInt("task_${taskName}_hours") ?? 0;
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
      await preferences.setInt(
          "task_${element.name}_secs", element.elapsedSeconds);
      await preferences.setInt(
          "task_${element.name}_mins", element.elapsedMinutes);
      await preferences.setInt(
          "task_${element.name}_hours", element.elapsedHours);
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

  List<Task> widgets() {
    return List<Task>.generate(
        tasks.length, (index) => Task(tm: tasks.elementAt(index)),
        growable: true);
  }
}

class TaskModel extends ChangeNotifier {
  TaskModel(this.name);

  String name = "unnamed";

  bool active = false;
  int elapsedSeconds = 0;
  int elapsedMinutes = 0;
  int elapsedHours = 0;
  Timer? timer;

  toggleActive() {
    if (active) {
      active = false;
      timer?.cancel();
    } else {
      active = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _increaseTime();
      });
    }

    notifyListeners();
  }

  _increaseTime() {
    _increaseElapsedSeconds();
    notifyListeners();
  }

  void _increaseElapsedSeconds() {
    if (elapsedSeconds < 59) {
      elapsedSeconds++;
    } else {
      elapsedSeconds = 0;
      _increaseElapsedMinutes();
    }
  }

  void _increaseElapsedMinutes() {
    if (elapsedMinutes < 59) {
      elapsedMinutes++;
      preferences.setInt("task_${name}_mins", elapsedMinutes);
    } else {
      elapsedMinutes = 0;
      elapsedHours++;
      preferences.setInt("task_${name}_hours", elapsedHours);
    }
  }

  String getTimeText() {
    if (elapsedHours > 0) {
      return "${elapsedHours}h:${elapsedMinutes}m:${elapsedSeconds}s";
    }
    if (elapsedMinutes > 0) return "${elapsedMinutes}m:${elapsedSeconds}s";
    return "${elapsedSeconds}s";
  }
}

class Task extends StatelessWidget {
  const Task({super.key, required this.tm});

  final TaskModel tm;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: tm,
      child: Consumer<TaskModel>(
        builder: (BuildContext context, model, Widget? child) {
          return Material(
            color: model.active ? Colors.green : Colors.white,
            child: InkWell(
              onTap: () {
                model.toggleActive();
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(model.name),
                    Text(model.getTimeText()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
