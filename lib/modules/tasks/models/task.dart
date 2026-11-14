class Task {
  const Task({required this.id, required this.summary, this.isDone = false});

  final String id;
  final String summary;
  final bool isDone;

  Task copyWith({bool? isDone}) {
    return Task(id: id, summary: summary, isDone: isDone ?? this.isDone);
  }
}
