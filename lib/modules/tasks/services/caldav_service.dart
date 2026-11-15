import 'package:caldav/caldav.dart' as cdav;

import '../models/caldav_account.dart';
import '../models/task.dart';
import '../models/task_list.dart';
import 'caldav_session.dart';

/// Failure already translated into something the UI can show as-is.
class CalDavException implements Exception {
  const CalDavException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// CalDAV tasks. Owns the session lifecycle and the failure modes — nothing
/// above this class sees a 401 or a DAV status.
class CalDavService {
  CalDavService({
    required this.account,
    Future<CalDavSession> Function(CaldavAccount account)? connect,
  }) : _connect = connect ?? PackageCalDavSession.connect;

  final CaldavAccount account;
  final Future<CalDavSession> Function(CaldavAccount account) _connect;

  CalDavSession? _session;

  Future<CalDavSession> _ensureSession() async {
    final existing = _session;
    if (existing != null) {
      return existing;
    }

    try {
      return _session = await _connect(account);
    } on CalDavException {
      rethrow;
    } on cdav.AuthenticationException {
      throw const CalDavException('Usuario o contraseña de CalDAV incorrectos');
    } on cdav.DiscoveryException {
      throw const CalDavException(
        'No se pudo descubrir el servidor CalDAV en esa dirección',
      );
    } on cdav.CalDavException catch (failure) {
      throw CalDavException(
        failure.message.isEmpty
            ? 'El servidor CalDAV rechazó la conexión'
            : failure.message,
      );
    } catch (_) {
      throw const CalDavException('No se pudo conectar con el servidor CalDAV');
    }
  }

  /// Task lists (VTODO calendars) of the account.
  Future<List<TaskList>> taskLists() async {
    final session = await _ensureSession();
    return _guard(session.taskLists);
  }

  Future<List<Task>> tasks(String listId) async {
    final session = await _ensureSession();
    return _guard(() => session.tasks(listId));
  }

  Future<void> setDone(Task task, bool done) async {
    final session = await _ensureSession();
    await _guard(() => session.setDone(task, done));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CalDavException {
      rethrow;
    } on cdav.CalDavException catch (failure) {
      throw CalDavException(
        failure.message.isEmpty
            ? 'El servidor CalDAV devolvió un error'
            : failure.message,
      );
    } catch (_) {
      throw const CalDavException('No se pudo leer la lista de tareas');
    }
  }

  void close() {
    _session?.close();
    _session = null;
  }
}
