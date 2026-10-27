import '../../domain/entities/todo.dart';

/// Model: sabe converter o Map vindo de fora na entidade do domínio.
class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    required super.done,
  });

  factory TodoModel.fromMap(Map<String, dynamic> map) => TodoModel(
        id: map['id'] as int,
        title: map['title'] as String,
        done: map['completed'] as bool,
      );
}
