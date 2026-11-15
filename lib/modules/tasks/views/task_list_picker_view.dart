import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/caldav_account.dart';
import '../services/caldav_provider.dart';
import '../view_models/task_list_picker_view_model.dart';

/// `9:102` for CalDAV — lists the account's VTODO calendars.
class TaskListPickerView extends StatefulWidget {
  const TaskListPickerView({super.key, required this.account});

  final CaldavAccount account;

  @override
  State<TaskListPickerView> createState() => _TaskListPickerViewState();
}

class _TaskListPickerViewState extends State<TaskListPickerView> {
  late final TaskListPickerViewModel _viewModel = TaskListPickerViewModel(
    CalDavProvider.serviceFor(widget.account.id)!,
  )..load();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: 'Select List',
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = _viewModel.error;
          if (error != null) {
            return _Message(text: error, onRetry: _viewModel.load);
          }

          final lists = _viewModel.lists;
          if (lists.isEmpty) {
            return const _Message(
              text: 'No hay listas de tareas en esta cuenta',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            itemCount: lists.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.controlGap),
            itemBuilder: (context, index) {
              final list = lists[index];
              return PrimaryButton(
                label: list.displayName,
                onPressed: () => Navigator.of(context).pop(list),
              );
            },
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.onLight),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
