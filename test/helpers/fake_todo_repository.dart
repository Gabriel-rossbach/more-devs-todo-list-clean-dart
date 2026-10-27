import 'package:todo_gabarito/modules/todos/domain/entities/todo.dart';
import 'package:todo_gabarito/modules/todos/domain/errors/todo_failure.dart';
import 'package:todo_gabarito/modules/todos/domain/repositories/todo_repository.dart';

/// Repositório falso: nada de internet, nada de Flutter.
class FakeTodoRepository implements TodoRepository {
  FakeTodoRepository([List<Todo>? todos])
      : _todos = todos ??
            const [
              Todo(id: 1, title: 'Estudar', done: false),
              Todo(id: 2, title: 'Exercício', done: true),
            ];

  final List<Todo> _todos;
  bool fail = false;

  @override
  Future<List<Todo>> getTodos() async {
    if (fail) throw const TodoFailure('Falha simulada');
    return List.of(_todos);
  }
}
