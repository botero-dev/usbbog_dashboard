import 'package:usbbog_dashboard/modules/tasks/models/task.dart';
import 'package:usbbog_dashboard/modules/tasks/models/task_list.dart';
import 'package:usbbog_dashboard/modules/tasks/services/caldav_service.dart';
import 'package:usbbog_dashboard/modules/tasks/services/caldav_session.dart';

/// In-memory CalDAV session: no network, records the writes it receives.
class FakeCalDavSession implements CalDavSession {
  FakeCalDavSession({
    List<TaskList>? lists,
    Map<String, List<Task>>? tasks,
    this.failOnWrite = false,
  }) : _lists = lists ?? const [TaskList(id: 'l1', displayName: 'Mis Tareas')],
       _tasks = {
         for (final entry in (tasks ?? const <String, List<Task>>{}).entries)
           entry.key: [...entry.value],
       };

  final List<TaskList> _lists;
  final Map<String, List<Task>> _tasks;

  final bool failOnWrite;
  final writes = <String>[];
  bool closed = false;

  @override
  Future<List<TaskList>> taskLists() async => _lists;

  @override
  Future<List<Task>> tasks(String listId) async => _tasks[listId] ?? const [];

  @override
  Future<void> setDone(Task task, bool done) async {
    if (failOnWrite) {
      throw const CalDavException('El servidor rechazó el cambio');
    }
    writes.add('${task.id}:$done');
    _tasks[task.listId] = [
      for (final current in _tasks[task.listId] ?? const <Task>[])
        current.id == task.id ? current.copyWith(isDone: done) : current,
    ];
  }

  @override
  void close() => closed = true;
}

const defaultTasks = [
  Task(id: 't1', summary: 'Leer los 4 acuerdos', listId: 'l1'),
  Task(id: 't2', summary: 'Llenar form idiomas', listId: 'l1'),
];
