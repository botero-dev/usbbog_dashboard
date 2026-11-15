import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/modules/tasks/models/caldav_account.dart';
import 'package:usbbog_dashboard/modules/tasks/services/caldav_service.dart';
import 'package:usbbog_dashboard/modules/tasks/view_models/tasks_view_model.dart';

import '../../support/fake_caldav_session.dart';

const account = CaldavAccount(
  id: 'a1',
  label: 'andres@example.com',
  baseUrl: 'https://caldav.example.com',
  username: 'andres@example.com',
  password: 'secret',
);

CalDavService serviceFor(FakeCalDavSession session) =>
    CalDavService(account: account, connect: (_) async => session);

void main() {
  test('without an account it asks for setup instead of failing', () async {
    final viewModel = TasksViewModel(null, listId: 'l1');

    await viewModel.load();

    expect(viewModel.needsSetup, isTrue);
    expect(viewModel.error, isNull);
    viewModel.dispose();
  });

  test('loads the tasks of the configured list', () async {
    final viewModel = TasksViewModel(
      serviceFor(FakeCalDavSession(tasks: {'l1': defaultTasks})),
      listId: 'l1',
    );

    await viewModel.load();

    expect(viewModel.tasks, hasLength(2));
    expect(viewModel.error, isNull);
    viewModel.dispose();
  });

  test('toggling flips the row and writes to the server', () async {
    final session = FakeCalDavSession(tasks: {'l1': defaultTasks});
    final viewModel = TasksViewModel(serviceFor(session), listId: 'l1');
    await viewModel.load();

    await viewModel.toggle(viewModel.tasks.first);

    expect(viewModel.tasks.first.isDone, isTrue);
    expect(session.writes, ['t1:true']);
    viewModel.dispose();
  });

  test('a rejected write reverts the row', () async {
    final viewModel = TasksViewModel(
      serviceFor(FakeCalDavSession(tasks: {'l1': defaultTasks})),
      listId: 'l1',
    );
    await viewModel.load();

    // A failing session only fails on write.
    final failing = TasksViewModel(
      serviceFor(
        FakeCalDavSession(tasks: {'l1': defaultTasks}, failOnWrite: true),
      ),
      listId: 'l1',
    );
    await failing.load();
    await failing.toggle(failing.tasks.first);

    expect(failing.tasks.first.isDone, isFalse);
    expect(failing.error, contains('rechazó'));
    viewModel.dispose();
    failing.dispose();
  });
}
