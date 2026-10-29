import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/entities/todo.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/update_todo.dart';

import '../../../../helpers/fake_todo_repository.dart';

void main() {
  test('UpdateTodo chama updateTodo no repositório', () async {
    final repository = FakeTodoRepository();
    final usecase = UpdateTodo(repository);

    final todo = Todo(id: 1, title: 'Novo título', done: true);

    await usecase(todo);

    final todos = await repository.getTodos();
    expect(todos.first.title, 'Novo título');
    expect(todos.first.done, isTrue);
  });
}