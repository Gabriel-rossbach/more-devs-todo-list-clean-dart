import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository repository;
  UpdateTodoUseCase(this.repository);

  /// Regra de negócio: quando [hideDone] é verdadeiro, esconde as concluídas.
  Future<List<Todo>> call({bool hideDone = false}) async {
    final todos = await repository.getTodos();
    return hideDone ? todos.where((t) => !t.done).toList() : todos;
  }
}
