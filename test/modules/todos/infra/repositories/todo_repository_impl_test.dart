import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/errors/todo_failure.dart';
import 'package:todo_gabarito/modules/todos/infra/datasources/todo_datasource.dart';
import 'package:todo_gabarito/modules/todos/infra/repositories/todo_repository_impl.dart';

class _Datasource implements TodoDatasource {
  final List<Map<String, dynamic>> _data = [
    {'id': 7, 'title': 'Ler o README', 'completed': true},
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchTodos() async => List.of(_data);

  @override
  Future<void> updateTodo(Map<String, dynamic> todo) async {
    final index = _data.indexWhere((t) => t['id'] == todo['id']);
    if (index != -1) {
      _data[index] = Map.from(todo);
    }
  }
}

class _BrokenDatasource implements TodoDatasource {
  @override
  Future<List<Map<String, dynamic>>> fetchTodos() async =>
      throw Exception('sem rede');

  @override
  Future<void> updateTodo(Map<String, dynamic> todo) async =>
      throw Exception('sem rede');
}

class _FailingUpdateDatasource implements TodoDatasource {
  final List<Map<String, dynamic>> _data = [
    {'id': 7, 'title': 'Ler o README', 'completed': true},
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchTodos() async => List.of(_data);

  @override
  Future<void> updateTodo(Map<String, dynamic> todo) async =>
      throw Exception('falha ao atualizar');
}

void main() {
  test('converte os Maps do datasource em entidades', () async {
    final repository = TodoRepositoryImpl(_Datasource());

    final todos = await repository.getTodos();

    expect(todos.single.id, 7);
    expect(todos.single.title, 'Ler o README');
    expect(todos.single.done, isTrue);
  });

  test('qualquer falha do datasource vira TodoFailure', () async {
    final repository = TodoRepositoryImpl(_BrokenDatasource());

    await expectLater(repository.getTodos(), throwsA(isA<TodoFailure>()));
  });

  test('toggleDone inverte o estado e atualiza cache local', () async {
    final datasource = _Datasource();
    final repository = TodoRepositoryImpl(datasource);

    // Primeiro carrega para popular o cache
    final todos = await repository.getTodos();
    final todo = todos.single;
    expect(todo.done, isTrue);

    // Inverte o estado
    await repository.toggleDone(todo);

    // Verifica se o cache foi atualizado (buscando do datasource que agora tem o dado atualizado)
    final updatedTodos = await repository.getTodos();
    expect(updatedTodos.single.done, isFalse);
  });

  test('toggleDone falha no datasource vira TodoFailure', () async {
    final repository = TodoRepositoryImpl(_FailingUpdateDatasource());

    // Carrega primeiro
    await repository.getTodos();
    final todo = (await repository.getTodos()).single;

    await expectLater(repository.toggleDone(todo), throwsA(isA<TodoFailure>()));
  });

  test('updateTodo atualiza título e status no cache', () async {
    final datasource = _Datasource();
    final repository = TodoRepositoryImpl(datasource);

    // Primeiro carrega para popular o cache
    await repository.getTodos();
    final todo = (await repository.getTodos()).single;
    expect(todo.title, 'Ler o README');
    expect(todo.done, isTrue);

    // Atualiza título e status
    await repository.updateTodo(todo.copyWith(title: 'Novo título', done: false));

    // Verifica se o cache foi atualizado (buscando do datasource que agora tem o dado atualizado)
    final updatedTodos = await repository.getTodos();
    expect(updatedTodos.single.title, 'Novo título');
    expect(updatedTodos.single.done, isFalse);
  });
}
