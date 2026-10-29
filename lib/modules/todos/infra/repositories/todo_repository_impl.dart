import '../../domain/entities/todo.dart';
import '../../domain/errors/todo_failure.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_datasource.dart';
import '../models/todo_model.dart';

//chamar o datasource e desserealizar a resposta
class TodoRepositoryImpl implements TodoRepository {
  final TodoDatasource datasource;
  TodoRepositoryImpl(this.datasource);

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final maps = await datasource.fetchTodos();
      return maps.map(TodoModel.fromMap).toList();
    } catch (_) {
      throw const TodoFailure('Não foi possível carregar as tarefas');
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    try {
      await datasource.updateTodo({
        'id': todo.id,
        'title': todo.title,
        'completed': todo.done,
      });
    } catch (_) {
      throw const TodoFailure('Não foi possível atualizar a tarefa');
    }
  }
}
