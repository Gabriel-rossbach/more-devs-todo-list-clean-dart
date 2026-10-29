import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/get_todos.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/update_todos_use_case.dart';
import 'package:todo_gabarito/modules/todos/presenter/todos_controller.dart';

import '../../../helpers/fake_todo_repository.dart';

TodosController _controller(FakeTodoRepository repository) => TodosController(
      getTodos: GetTodosUseCase(repository),
      updateUseCase: UpdateTodoUseCase(repository),
    );

void main() {
  test('load preenche a lista e desliga o carregamento', () async {
    final controller = _controller(FakeTodoRepository());

    await controller.load();

    expect(controller.todos, hasLength(2));
    expect(controller.loading, isFalse);
    expect(controller.error, isNull);
  });

  test('falha do domínio vira mensagem de erro', () async {
    final repository = FakeTodoRepository()..fail = true;
    final controller = _controller(repository);

    await controller.load();

    expect(controller.error, 'Falha simulada');
    expect(controller.todos, isEmpty);
  });

  test('updateTodoItem atualiza a tarefa no repositório', () async {
    final repository = FakeTodoRepository();
    final controller = _controller(repository);
    await controller.load();

    final todo = controller.todos.first;
    await controller
        .updateTodoItem(todo.copyWith(title: 'Atualizado', done: true));

    // Verifica se o repositório foi atualizado
    final updatedTodos = await repository.getTodos();
    expect(updatedTodos.first.title, 'Atualizado');
    expect(updatedTodos.first.done, isTrue);
    expect(controller.loading, isFalse);
    expect(controller.error, isNull);
  });
}
