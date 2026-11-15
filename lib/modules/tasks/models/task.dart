/// A VTODO from a CalDAV task list.
class Task {
  const Task({
    required this.id,
    required this.summary,
    this.listId = '',
    this.isDone = false,
    this.due,
  });

  /// VTODO uid.
  final String id;
  final String summary;

  /// Calendar uid the task belongs to.
  final String listId;
  final bool isDone;
  final DateTime? due;

  Task copyWith({bool? isDone}) {
    return Task(
      id: id,
      summary: summary,
      listId: listId,
      isDone: isDone ?? this.isDone,
      due: due,
    );
  }
}
