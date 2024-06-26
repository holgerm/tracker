import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/src/tasks_manager.dart';
import 'package:tracker/src/tracker.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({super.key, required this.tm});

  final TaskModel tm;

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
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
          TasksManager.instance?.deleteTask(model);
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
