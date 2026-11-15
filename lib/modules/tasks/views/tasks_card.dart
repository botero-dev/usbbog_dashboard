import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/surface_card.dart';
import '../models/task.dart';
import '../services/caldav_provider.dart';
import '../view_models/tasks_view_model.dart';
import 'widgets/checkbox_row.dart';

/// Dashboard to-do tile (`9:46`).
class TasksCard extends StatefulWidget {
  const TasksCard({super.key, this.accountId, this.listId, this.onLongPress});

  /// CalDAV account; empty means "not configured yet".
  final String? accountId;
  final String? listId;
  final VoidCallback? onLongPress;

  @override
  State<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends State<TasksCard> {
  static const _maxVisible = 5;

  late final TasksViewModel _viewModel = TasksViewModel(
    CalDavProvider.serviceFor(widget.accountId),
    listId: widget.listId,
  )..load();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onLongPress: widget.onLongPress,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tus tareas:', style: AppText.title),
            const SizedBox(height: 8),
            if (_viewModel.needsSetup)
              const _Hint('Agrega una cuenta CalDAV desde el botón +')
            else
              AsyncView(
                isLoading: _viewModel.isLoading,
                error: _viewModel.error,
                onRetry: _viewModel.load,
                builder: (context) => _list(_viewModel.tasks),
              ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const _Hint('No hay tareas en esta lista');
    }

    return Column(
      children: [
        for (final task in tasks.take(_maxVisible))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CheckboxRow(
              task: task,
              onChanged: () => _viewModel.toggle(task),
            ),
          ),
        if (tasks.length > _maxVisible)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+${tasks.length - _maxVisible} más',
              style: AppText.caption.copyWith(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message, style: AppText.body.copyWith(color: Colors.white70)),
    );
  }
}
