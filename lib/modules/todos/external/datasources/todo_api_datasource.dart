import 'package:dio/dio.dart';

import '../../infra/datasources/todo_datasource.dart';

/// Única classe do app que conhece o Dio.
class TodoApiDatasource implements TodoDatasource {
  final Dio dio;
  TodoApiDatasource(this.dio);

  @override
  Future<List<Map<String, dynamic>>> fetchTodos() async {
    final res = await dio.get<List<dynamic>>('/todos');
    return res.data!.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateTodo(Map<String, dynamic> todo) async {
    await dio.patch('/todos/${todo['id']}', data: {
      'title': todo['title'],
      'completed': todo['completed'],
    });
  }
}
