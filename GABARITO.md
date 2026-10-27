# Gabarito da aula: Clean Dart no Flutter

## Prática em duplas — marcar tarefa como concluída

A ordem esperada é de dentro para fora. Cada passo aponta o arquivo do gabarito.

| Passo | Camada | O que fazer | Arquivo |
| --- | --- | --- | --- |
| 1 | Domain | Adicionar `Future<void> toggleDone(Todo todo)` ao contrato e criar o caso de uso `ToggleTodo` | `domain/repositories/todo_repository.dart`, `domain/usecases/toggle_todo.dart` |
| 2 | Domain (teste) | Testar `ToggleTodo` com o repositório falso antes de mexer nas outras camadas | `test/modules/todos/domain/usecases/toggle_todo_test.dart` |
| 3 | Infra | Adicionar `updateTodo(int id, bool done)` ao contrato do datasource e implementar `toggleDone` no `TodoRepositoryImpl`, convertendo falhas em `TodoFailure` | `infra/datasources/todo_datasource.dart`, `infra/repositories/todo_repository_impl.dart` |
| 4 | External | Implementar `updateTodo` no `TodoApiDatasource` com `dio.patch('/todos/$id', data: {'completed': done})` | `external/datasources/todo_api_datasource.dart` |
| 5 | Presenter | Criar `toggle(Todo todo)` no controller, que executa `ToggleTodo` e atualiza a lista; na página, o `onTap` só chama `controller.toggle(t)` | `presenter/todos_controller.dart`, `presenter/todos_page.dart` |

### Pontos de atenção na correção

- **O Domain não importa nada de fora.** Nenhum arquivo de `domain/` importa Flutter, Dio ou algo de `infra/`.
- **A External só conhece o Dio.** `DioException` nunca aparece fora de `external/`. O `TodoRepositoryImpl` captura qualquer erro com `catch (_)` e lança `TodoFailure`.
- **O controller não conhece repositórios.** Ele recebe `GetTodos` e `ToggleTodo`, nunca `TodoRepositoryImpl`.
- **A página não tem regra.** O `onTap` é uma linha: `controller.toggle(t)`.
- **O teste veio primeiro.** O teste do `ToggleTodo` roda sem internet e sem Flutter.

### Armadilha do JSONPlaceholder

A API aceita o `PATCH`, mas não grava. Duplas que recarregam a lista pela API depois de marcar vão ver a tarefa voltar ao estado anterior. No gabarito, o repositório guarda a lista em memória e a atualiza após o `toggleDone`. Vale discutir com a turma: isso faz do repositório a fonte única da verdade.

## Desafio extra — datasource em memória

`TodoLocalDatasource` implementa o mesmo contrato `TodoDatasource` guardando uma lista de `Map` em memória. A troca acontece só no `main.dart`:

```bash
flutter run --dart-define=LOCAL=true
```

Domain, Infra e Presenter não mudam uma linha. É a prova prática da regra de dependência.

## Tíquete de saída — respostas esperadas

1. **Em qual camada fica a chamada `dio.get`? E o `fromMap`?**
   `dio.get` fica na External, no `TodoApiDatasource`. O `fromMap` fica na Infra, no `TodoModel`. São camadas diferentes porque buscar o dado bruto (External) muda quando a fonte muda, e adaptar o dado ao contrato do domínio (Infra) muda quando o formato muda.

2. **Por que o contrato `TodoDatasource` fica na Infra e não na External?**
   Porque quem usa define o contrato. Quem chama `fetchTodos` é o `TodoRepositoryImpl`, na Infra. A External só implementa. Assim a Infra não depende da External, e sim o contrário.

3. **O que mudaria para trocar a API por um banco local?**
   Só a External: uma nova classe que implementa `TodoDatasource` usando o banco, e a linha do `main.dart` que escolhe a implementação. Domain, Infra e Presenter continuam iguais, como mostra o desafio extra.

## Testes incluídos

| Teste | O que prova |
| --- | --- |
| `get_todos_test.dart` | A regra de esconder concluídas funciona sem rede |
| `toggle_todo_test.dart` | O caso de uso delega ao repositório (prática, passo 2) |
| `todo_repository_impl_test.dart` | Conversão de `Map` para entidade, atualização em memória e tradução de erros para `TodoFailure` |
| `todos_controller_test.dart` | Estado de carregamento, toggle e mensagem de erro |
| `widget_test.dart` | Tocar numa tarefa marca como concluída na tela |
