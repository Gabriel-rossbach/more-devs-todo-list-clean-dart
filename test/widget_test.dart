import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/get_todos.dart';
import 'package:todo_gabarito/modules/todos/presenter/todos_controller.dart';
import 'package:todo_gabarito/modules/todos/presenter/todos_page.dart';

import 'helpers/fake_todo_repository.dart';

void main() {
  testWidgets('exibe o status das tarefas', (tester) async {
    final repository = FakeTodoRepository();
    final controller = TodosController(
      getTodos: GetTodos(repository),
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(home: TodosPage(controller: controller)),
    );
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
