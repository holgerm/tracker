import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/main.dart';

class TasksModel extends ChangeNotifier {
  static const String prefKeyTaskNames = "tasknames";

  static TasksModel? instance;

  TasksModel() {
    init();
    TasksModel.instance = this;
  }

  Future<void> init() async {
    List<String> taskNames =
        preferences.getStringList(prefKeyTaskNames) ?? <String>[];
    for (final taskName in taskNames) {
      var tm = TaskModel(taskName);
      int? startTimeMS = preferences.getInt("task_${taskName}_startTime");
      if (startTimeMS != null) {
        tm.startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMS);
        tm._setActive();
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

  List<Task> widgets() {
    return List<Task>.generate(
        tasks.length, (index) => Task(tm: tasks.elementAt(index)),
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
    if (active) {
      active = false;
      timer?.cancel();
      _setDuration(duration + DateTime.now().difference(startTime!));
      _setStartTime(null);
      preferences.remove("task_${name}_startTime");
    } else {
      _setStartTime(DateTime.now());
      _setActive();
    }

    notifyListeners();
  }

  void _setActive() {
    active = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _increaseTime();
    });
  }

  _increaseTime() {
    // _increaseElapsedSeconds();
    notifyListeners();
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
    if (active) toggleActive();
    _setDuration(const Duration());
    _setStartTime(null);
    notifyListeners();
  }
}

class Task extends StatefulWidget {
  const Task({super.key, required this.tm});

  final TaskModel tm;

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.tm,
      child: Consumer<TaskModel>(
        builder: (BuildContext context, model, Widget? child) {
          return GestureDetector(
            onLongPress: () => _showCustomMenu(context, model),
            onTapDown: _storePosition,
            child: Material(
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
                      Text(model.getTimeString()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset? _tapPosition;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _showCustomMenu(BuildContext context, TaskModel model) {
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
            context: context,
            items: const <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  // title: Text('Delete'),
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.replay),
                  //title: Text('Reset'),
                ),
              ),
            ],
            position: RelativeRect.fromRect(
                _tapPosition! &
                    const Size(20, 40), // smaller rect, the touch area
                Offset.zero & overlay.size // Bigger rect, the entire screen
                ))
        .then((value) {
      switch (value) {
        case 'delete':
          TasksModel.instance?.deleteTask(model);
          break;
        case 'reset':
          model.reset();
          break;
        default:
          return;
      }
    });
  }
}
