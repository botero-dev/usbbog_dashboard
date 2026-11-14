import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/surface_card.dart';
import '../models/task.dart';
import 'widgets/checkbox_row.dart';

/// Dashboard to-do tile (`9:46`).
class TasksCard extends StatefulWidget {
  const TasksCard({super.key, this.onLongPress});

  final VoidCallback? onLongPress;

  @override
  State<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends State<TasksCard> {
  // Replaced by `caldav_service.getTodos` in M4; toggling then writes back.
  static const _demoTasks = [
    Task(id: '1', summary: 'Entregar proyecto de clase'),
    Task(id: '2', summary: 'Entregar proyecto de clase'),
    Task(id: '3', summary: 'Entregar proyecto de clase'),
  ];

  List<Task> _tasks = _demoTasks;

  void _toggle(Task task) {
    setState(() {
      _tasks = [
        for (final current in _tasks)
          current.id == task.id
              ? current.copyWith(isDone: !current.isDone)
              : current,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onLongPress: widget.onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tus tareas:', style: AppText.title),
          for (final task in _tasks)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CheckboxRow(task: task, onChanged: () => _toggle(task)),
            ),
        ],
      ),
    );
  }
}
