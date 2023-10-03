import 'package:flutter/material.dart';

class TasksModel extends ChangeNotifier {
  List<TaskModel> tasks = List<TaskModel>.empty(growable: true);

  addTask(String name) {
    if (name.isEmpty) name = "Unnamed Task";
    tasks.add(TaskModel(name));
    notifyListeners();
  }

  List<Task> widgets() {
    return List<Task>.generate(tasks.length, (index) => Task(tm: tasks[index]),
        growable: true);
  }
}

class TaskModel {
  String name = "unnamed";

  TaskModel(this.name);
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
    return Text(widget.tm.name);
  }
}
