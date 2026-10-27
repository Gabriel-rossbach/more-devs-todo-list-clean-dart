import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/get_todos.dart';

import '../../../../helpers/fake_todo_repository.dart';

void main() {
  test('GetTodos devolve todas as tarefas por padrão', () async {
    final usecase = GetTodos(FakeTodoRepository());

    final result = await usecase();

    expect(result.map((t) => t.id), [1, 2]);
  });

  test('GetTodos esconde as concluídas quando hideDone é verdadeiro', () async {
    final usecase = GetTodos(FakeTodoRepository());

    final result = await usecase(hideDone: true);

    expect(result.map((t) => t.id), [1]);
  });
}
