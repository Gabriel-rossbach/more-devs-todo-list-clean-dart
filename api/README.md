# Todo API

API simples para o app Flutter.

## Endpoints

### `GET /todos`

Retorna a lista de tarefas:

```json
[
  { "id": 1, "title": "Estudar Clean Dart", "completed": false }
]
```

### `PATCH /todos/:id`

Atualiza o status da tarefa:

```json
{ "completed": true }
```

A resposta retorna a tarefa atualizada.

## Rodar localmente

```bash
cd api
npm install
npm start
```

A API fica disponível em `http://localhost:3000`.

## Railway

Crie um novo serviço no Railway apontando para este repositório e configure o **Root Directory** como `/api`. O Railway executará `npm start` e fornecerá a variável `PORT` automaticamente.

Depois de publicar, configure a URL pública no app Flutter, substituindo a `baseUrl` em `lib/main.dart`:

```dart
Dio(BaseOptions(baseUrl: 'https://SEU-SERVICO.up.railway.app'))
```

O armazenamento atual é em memória. Os dados retornam ao estado inicial quando o serviço reinicia ou é redeployado.
