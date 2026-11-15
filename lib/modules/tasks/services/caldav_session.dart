import 'package:caldav/caldav.dart' as cdav;

import '../models/caldav_account.dart';
import '../models/task.dart';
import '../models/task_list.dart';

/// The bits of the `caldav` package the app uses. Exists so the service can be
/// tested without a server: tests implement this instead of faking Dio.
abstract interface class CalDavSession {
  Future<List<TaskList>> taskLists();

  Future<List<Task>> tasks(String listId);

  Future<void> setDone(Task task, bool done);

  void close();
}

/// Real implementation, backed by the `caldav` package.
class PackageCalDavSession implements CalDavSession {
  PackageCalDavSession._(this._client);

  final cdav.CalDavClient _client;
  final Map<String, cdav.Calendar> _calendars = {};

  /// Discovery-first, instead of the package's `CalDavClient.connect`.
  ///
  /// `connect()` verifies the credentials with a PROPFIND on the bare host,
  /// which some servers (Fastmail among them) answer with 404, making valid
  /// credentials look wrong. Discovery starts from `/.well-known/caldav` and
  /// still maps a 401 from the principal lookup to `AuthenticationException`.
  static Future<PackageCalDavSession> connect(CaldavAccount account) async {
    final client = cdav.CalDavClient(
      baseUrl: account.baseUrl,
      username: account.username,
      password: account.password,
      // Only when the user typed http:// — a LAN CalDAV server.
      allowInsecure: account.baseUrl.startsWith('http://'),
    );

    try {
      await client.discover();
    } catch (_) {
      client.close();
      rethrow;
    }

    return PackageCalDavSession._(client);
  }

  @override
  Future<List<TaskList>> taskLists() async {
    final calendars = await _client.getCalendars();
    _calendars
      ..clear()
      ..addEntries(
        calendars
            .where((calendar) => calendar.supportsTodos && !calendar.isReadOnly)
            .map((calendar) => MapEntry(calendar.uid, calendar)),
      );

    return [
      for (final calendar in _calendars.values)
        TaskList(
          id: calendar.uid,
          displayName: calendar.displayName.isEmpty
              ? 'Tareas'
              : calendar.displayName,
        ),
    ]..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  @override
  Future<List<Task>> tasks(String listId) async {
    final calendar = await _calendarFor(listId);
    final todos = await _client.getTodos(calendar);

    return [
      for (final todo in todos)
        Task(
          id: todo.uid,
          summary: todo.summary,
          listId: listId,
          isDone: todo.isCompleted,
          due: todo.due,
        ),
    ];
  }

  @override
  Future<void> setDone(Task task, bool done) async {
    final calendar = await _calendarFor(task.listId);
    final todos = await _client.getTodos(calendar);
    final match = todos.where((todo) => todo.uid == task.id).firstOrNull;
    if (match == null) {
      throw const cdav.NotFoundException('No se encontró la tarea');
    }

    await _client.updateTodo(_withDone(match, done));
  }

  /// `CalendarTodo.copyWith` cannot clear `completed`, so a done → not-done
  /// transition needs a fresh instance.
  cdav.CalendarTodo _withDone(cdav.CalendarTodo todo, bool done) {
    return cdav.CalendarTodo(
      uid: todo.uid,
      calendarId: todo.calendarId,
      href: todo.href,
      etag: todo.etag,
      summary: todo.summary,
      description: todo.description,
      location: todo.location,
      dtstart: todo.dtstart,
      due: todo.due,
      isAllDay: todo.isAllDay,
      status: done ? cdav.TodoStatus.completed : cdav.TodoStatus.needsAction,
      completed: done ? DateTime.now().toUtc() : null,
      percentComplete: done ? 100 : null,
      priority: todo.priority,
      rawIcalendar: todo.rawIcalendar,
      isReadOnly: todo.isReadOnly,
      rrule: todo.rrule,
      recurrenceId: todo.recurrenceId,
      exdate: todo.exdate,
    );
  }

  Future<cdav.Calendar> _calendarFor(String listId) async {
    final cached = _calendars[listId];
    if (cached != null) {
      return cached;
    }
    await taskLists();
    final refreshed = _calendars[listId];
    if (refreshed == null) {
      throw const cdav.NotFoundException('No se encontró la lista de tareas');
    }
    return refreshed;
  }

  @override
  void close() => _client.close();
}
