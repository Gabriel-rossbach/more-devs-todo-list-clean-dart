/// Contrato do datasource: fica na Infra porque é a Infra quem o usa.
/// A External só implementa.
abstract interface class TodoDatasource {
  Future<List<Map<String, dynamic>>> fetchTodos();
  Future<void> updateTodo(Map<String, dynamic> todo);
}
