import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodos {
  final TodoRepository repository;
  GetTodos(this.repository);

  /// Regra de negócio: quando [hideDone] é verdadeiro, esconde as concluídas.
  Future<List<Todo>> call({bool hideDone = false}) async {
    final todos = await repository.getTodos();
    return hideDone ? todos.where((t) => !t.done).toList() : todos;
  }
}
