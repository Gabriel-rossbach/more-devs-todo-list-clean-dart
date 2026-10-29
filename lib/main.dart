import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/update_todo.dart';

import 'modules/habits/presenter/habits_page.dart';
import 'modules/todos/domain/usecases/get_todos.dart';
import 'modules/todos/external/datasources/todo_api_datasource.dart';
import 'modules/todos/infra/datasources/todo_datasource.dart';
import 'modules/todos/infra/repositories/todo_repository_impl.dart';
import 'modules/todos/presenter/todos_controller.dart';
import 'modules/todos/presenter/todos_page.dart';

/// Único lugar que sabe quais implementações usar.
void main() {
  final TodoDatasource datasource = TodoApiDatasource(
    Dio(BaseOptions(
        baseUrl: 'https://todo-api-production-62d2.up.railway.app')),
  );
  final repository = TodoRepositoryImpl(datasource);
  final controller = TodosController(
    updateTodo: UpdateTodo(repository),
    getTodos: GetTodosUseCase(repository),
  )..load();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315CFF)),
    ),
    home: HomeShell(
      pages: [
        TodosPage(controller: controller),
        // TODO(aluno): passar o HabitsController para a página.
        const HabitsPage(),
      ],
    ),
  ));
}

/// Navegação entre os módulos. Fica aqui para um módulo não importar o outro.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.pages});

  final List<Widget> pages;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: widget.pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_rounded),
            label: 'Hábitos',
          ),
        ],
      ),
    );
  }
}
