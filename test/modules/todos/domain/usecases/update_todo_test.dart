import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/update_todos_use_case.dart';

import '../../../../helpers/fake_todo_repository.dart';

void main() {
  test('UpdateTodoUseCase filtra concluídas quando hideDone é verdadeiro', () async {
    final repository = FakeTodoRepository();
    final usecase = UpdateTodoUseCase(repository);

    final result = await usecase(hideDone: true);

    expect(result.map((t) => t.id), [1]); // Apenas a não concluída (id: 1)
  });
}