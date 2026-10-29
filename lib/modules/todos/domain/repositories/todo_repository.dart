import '../entities/todo.dart';

/// Contrato definido por quem usa (os casos de uso) e implementado na Infra.
abstract interface class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<void> updateTodo(Todo todo);
}
