# todo_gabarito — Clean Dart resolvido

Gabarito da aula de arquitetura em camadas. É o `todo_base` refatorado para as quatro camadas do Clean Dart, com:

  - leitura de tarefas pela API publicada no Railway;
- **testes** de caso de uso, repositório, controller e página, todos sem internet.

## Como rodar

```bash
flutter create . --project-name todo_gabarito
flutter pub get
flutter test                              # roda todos os testes
  flutter run                               # usa a API do Railway via Dio
```

O `flutter create` só gera as pastas de plataforma; não sobrescreve `lib/` nem `test/`.

## Estrutura

```text
lib/
  main.dart                                  composição da aplicação
  modules/todos/
    domain/
      entities/todo.dart
      errors/todo_failure.dart
      repositories/todo_repository.dart      contrato: getTodos
      usecases/get_todos.dart                regra: esconder concluídas
    infra/
      datasources/todo_datasource.dart       contrato: fetchTodos
      models/todo_model.dart                 fromMap
      repositories/todo_repository_impl.dart converte e trata erros
    external/
      datasources/todo_api_datasource.dart   Dio: GET /todos
    presenter/
      todos_controller.dart                  ChangeNotifier
      todos_page.dart                        ListenableBuilder
test/
  helpers/fake_todo_repository.dart
  modules/todos/domain/usecases/get_todos_test.dart
  modules/todos/domain/usecases/toggle_todo_test.dart
  modules/todos/infra/repositories/todo_repository_impl_test.dart
  modules/todos/presenter/todos_controller_test.dart
  widget_test.dart
```

## Fonte dos dados

As tarefas são carregadas do endpoint `/todos` da API publicada no Railway. A documentação Swagger está disponível em `https://todo-api-production-62d2.up.railway.app/docs` e o contrato OpenAPI em `/openapi.json`.
