import 'package:flutter/foundation.dart';

import '../models/task_list.dart';
import '../services/caldav_service.dart';

/// Backs the "Select List" step of the tasks widget.
class TaskListPickerViewModel extends ChangeNotifier {
  TaskListPickerViewModel(this._service);

  final CalDavService _service;

  List<TaskList> lists = const [];
  bool isLoading = false;
  String? error;

  bool _disposed = false;

  Future<void> load() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    _notify();

    try {
      lists = await _service.taskLists();
    } on CalDavException catch (failure) {
      error = failure.message;
    }

    isLoading = false;
    _notify();
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
