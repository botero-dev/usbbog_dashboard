import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/caldav_service.dart';

/// Backs the dashboard to-do card.
class TasksViewModel extends ChangeNotifier {
  TasksViewModel(this._service, {required this.listId});

  final String? listId;
  final CalDavService? _service;

  List<Task> tasks = const [];
  bool isLoading = false;
  String? error;

  /// True when no CalDAV account is configured yet.
  bool get needsSetup => _service == null;

  bool _disposed = false;

  Future<void> load() async {
    final service = _service;
    if (service == null || isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    _notify();

    try {
      tasks = await service.tasks(listId ?? '');
    } on CalDavException catch (failure) {
      error = failure.message;
    }

    isLoading = false;
    _notify();
  }

  /// Optimistic toggle: the row flips immediately and reverts if the server
  /// rejects the change, so the UI never lies about what is stored.
  Future<void> toggle(Task task) async {
    final service = _service;
    if (service == null) {
      return;
    }

    final before = tasks;
    tasks = [
      for (final current in tasks)
        current.id == task.id
            ? current.copyWith(isDone: !current.isDone)
            : current,
    ];
    error = null;
    _notify();

    try {
      await service.setDone(task, !task.isDone);
    } on CalDavException catch (failure) {
      tasks = before;
      error = failure.message;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
