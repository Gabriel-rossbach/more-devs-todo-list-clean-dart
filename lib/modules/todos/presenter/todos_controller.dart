import 'package:flutter/foundation.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/update_todos_use_case.dart';

import '../domain/entities/todo.dart';
import '../domain/errors/todo_failure.dart';
import '../domain/usecases/get_todos.dart';

class TodosController extends ChangeNotifier {
  TodosController({required this.getTodos, required this.updateUseCase});

  final GetTodosUseCase getTodos;
  final UpdateTodoUseCase updateUseCase;

  List<Todo> todos = [];
  bool loading = false;
  String? error;
  bool hideDone = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      todos = await getTodos(hideDone: hideDone);
    } on TodoFailure catch (f) {
      error = f.message;
    }
    loading = false;
    notifyListeners();
  }

  void toggleHideDone() {
    hideDone = !hideDone;
    load();
  }
}
