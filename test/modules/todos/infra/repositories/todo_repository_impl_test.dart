import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/errors/todo_failure.dart';
import 'package:todo_gabarito/modules/todos/infra/datasources/todo_datasource.dart';
import 'package:todo_gabarito/modules/todos/infra/repositories/todo_repository_impl.dart';

class _Datasource implements TodoDatasource {
  @override
  Future<List<Map<String, dynamic>>> fetchTodos() async => [
        {'id': 7, 'title': 'Ler o README', 'completed': true},
      ];
}

class _BrokenDatasource implements TodoDatasource {
  @override
  Future<List<Map<String, dynamic>>> fetchTodos() async =>
      throw Exception('sem rede');
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
}
