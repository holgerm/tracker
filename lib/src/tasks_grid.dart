import 'package:flutter/material.dart';
import 'package:tracker/src/tasks_manager.dart';
import 'package:provider/provider.dart';

class TasksGrid extends StatefulWidget {
  const TasksGrid({super.key});

  @override
  State<TasksGrid> createState() => _TasksGridState();
}

class _TasksGridState extends State<TasksGrid> {
  late TextEditingController controller;
  bool enableSubmit = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Your Tasks"),
      ),
      body: Consumer<TasksManager>(
        builder: (BuildContext context, model, Widget? child) {
          return GridView.count(
            crossAxisCount: 2,
            children: model.widgets(),
          );
        },
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            right: 12.0,
            bottom: 25.0,
            child: FloatingActionButton(
              heroTag: "add",
              onPressed: () {
                openNewTaskDialog(context);
              },
              tooltip: 'Add Task',
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            left: 38.0,
            bottom: 25.0,
            child: FloatingActionButton(
              heroTag: "settings",
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              tooltip: 'Settings',
              child: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }

  openNewTaskDialog(BuildContext context) {
    void submit() {
      Provider.of<TasksManager>(context, listen: false)
          .addTask(controller.text);
      Navigator.of(context).pop();
      controller.text = "";
      enableSubmit = false;
    }

    void press() {
      if (enableSubmit) submit();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add new Task:'),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Enter the name of your task'),
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    enableSubmit = value.isNotEmpty;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: enableSubmit ? press : null,
                  child: const Text('SUBMIT'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
