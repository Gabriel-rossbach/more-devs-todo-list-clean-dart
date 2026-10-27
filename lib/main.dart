import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'modules/todos/domain/usecases/get_todos.dart';
import 'modules/todos/external/datasources/todo_api_datasource.dart';
import 'modules/todos/infra/datasources/todo_datasource.dart';
import 'modules/todos/infra/repositories/todo_repository_impl.dart';
import 'modules/todos/presenter/todos_controller.dart';
import 'modules/todos/presenter/todos_page.dart';

/// Único lugar que sabe quais implementações usar.
void main() {
  final TodoDatasource datasource = TodoApiDatasource(
    Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
  );
  final repository = TodoRepositoryImpl(datasource);
  final controller = TodosController(
    getTodos: GetTodos(repository),
  )..load();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodosPage(controller: controller),
  ));
}
