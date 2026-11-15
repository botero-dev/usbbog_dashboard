import 'package:caldav/caldav.dart' as cdav;
import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/modules/tasks/models/caldav_account.dart';
import 'package:usbbog_dashboard/modules/tasks/services/caldav_service.dart';

import '../../support/fake_caldav_session.dart';

const account = CaldavAccount(
  id: 'a1',
  label: 'andres@example.com',
  baseUrl: 'https://caldav.example.com',
  username: 'andres@example.com',
  password: 'secret',
);

CalDavService buildService(FakeCalDavSession session, {int? failWith}) {
  return CalDavService(
    account: account,
    connect: (_) async {
      if (failWith == 401) {
        throw const cdav.AuthenticationException();
      }
      return session;
    },
  );
}

void main() {
  test('taskLists() returns the session lists', () async {
    final service = buildService(FakeCalDavSession());

    final lists = await service.taskLists();

    expect(lists.single.displayName, 'Mis Tareas');
  });

  test('tasks() maps the list contents', () async {
    final service = buildService(
      FakeCalDavSession(tasks: {'l1': defaultTasks}),
    );

    final tasks = await service.tasks('l1');

    expect(tasks.map((t) => t.summary), [
      'Leer los 4 acuerdos',
      'Llenar form idiomas',
    ]);
    expect(tasks.every((t) => t.isDone), isFalse);
  });

  test('setDone() forwards the write', () async {
    final session = FakeCalDavSession(tasks: {'l1': defaultTasks});
    final service = buildService(session);

    await service.setDone(defaultTasks.first, true);

    expect(session.writes, ['t1:true']);
  });

  test('connects once for several calls', () async {
    var connects = 0;
    final service = CalDavService(
      account: account,
      connect: (_) async {
        connects++;
        return FakeCalDavSession(tasks: {'l1': defaultTasks});
      },
    );

    await service.taskLists();
    await service.tasks('l1');
    await service.tasks('l1');

    expect(connects, 1);
  });

  test('auth failure surfaces a readable message', () async {
    final service = buildService(FakeCalDavSession(), failWith: 401);

    expect(
      () => service.taskLists(),
      throwsA(
        isA<CalDavException>().having(
          (e) => e.message,
          'message',
          contains('contraseña'),
        ),
      ),
    );
  });

  test('an unexpected error becomes a CalDavException', () async {
    final service = CalDavService(
      account: account,
      connect: (_) async => throw const SocketExceptionStub(),
    );

    expect(() => service.taskLists(), throwsA(isA<CalDavException>()));
  });
}

class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
