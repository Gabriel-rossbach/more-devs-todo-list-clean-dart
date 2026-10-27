class Todo {
  final int id;
  final String title;
  final bool done;

  const Todo({required this.id, required this.title, required this.done});

  Todo copyWith({String? title, bool? done}) =>
      Todo(id: id, title: title ?? this.title, done: done ?? this.done);
}
