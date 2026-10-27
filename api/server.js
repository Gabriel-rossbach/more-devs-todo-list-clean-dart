const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const openapiDocument = {
    openapi: '3.0.3',
    info: {
        title: 'Todo Gabarito API',
        version: '1.0.0',
        description: 'API para listar e atualizar tarefas.',
    },
    servers: [{ url: '/' }],
    paths: {
        '/': {
            get: {
                summary: 'Verifica o status da API',
                responses: {
                    200: {
                        description: 'API online',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Status' },
                            },
                        },
                    },
                },
            },
        },
        '/todos': {
            get: {
                summary: 'Lista as tarefas',
                responses: {
                    200: {
                        description: 'Lista de tarefas',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'array',
                                    items: { $ref: '#/components/schemas/Todo' },
                                },
                            },
                        },
                    },
                },
            },
        },
        '/todos/{id}': {
            patch: {
                summary: 'Atualiza o status de uma tarefa',
                parameters: [{
                    name: 'id',
                    in: 'path',
                    required: true,
                    schema: { type: 'integer', example: 1 },
                }],
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: {
                                type: 'object',
                                required: ['completed'],
                                properties: { completed: { type: 'boolean', example: true } },
                            },
                        },
                    },
                },
                responses: {
                    200: {
                        description: 'Tarefa atualizada',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Todo' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    404: { description: 'Tarefa não encontrada' },
                },
            },
        },
    },
    components: {
        schemas: {
            Todo: {
                type: 'object',
                required: ['id', 'title', 'completed'],
                properties: {
                    id: { type: 'integer', example: 1 },
                    title: { type: 'string', example: 'Estudar Clean Dart' },
                    completed: { type: 'boolean', example: false },
                },
            },
            Status: {
                type: 'object',
                properties: {
                    name: { type: 'string', example: 'todo-gabarito-api' },
                    status: { type: 'string', example: 'ok' },
                },
            },
        },
    },
};

app.get('/openapi.json', (_request, response) => response.json(openapiDocument));
app.use('/docs', swaggerUi.serve, swaggerUi.setup(openapiDocument));

let todos = [
    { id: 1, title: 'Estudar Clean Dart', completed: false },
    { id: 2, title: 'Fazer o exercício da aula', completed: false },
    { id: 3, title: 'Rever o diagrama de camadas', completed: true },
    { id: 4, title: 'Publicar a API no Railway', completed: false },
];

app.get('/', (_request, response) => {
    response.json({ name: 'todo-gabarito-api', status: 'ok' });
});

app.get('/todos', (_request, response) => {
    response.json(todos);
});

app.patch('/todos/:id', (request, response) => {
    const id = Number(request.params.id);
    const { completed } = request.body;

    if (!Number.isInteger(id)) {
        return response.status(400).json({ error: 'O id deve ser um número inteiro.' });
    }

    if (typeof completed !== 'boolean') {
        return response
            .status(400)
            .json({ error: 'O campo completed deve ser booleano.' });
    }

    const todo = todos.find((item) => item.id === id);
    if (!todo) {
        return response.status(404).json({ error: 'Tarefa não encontrada.' });
    }

    todo.completed = completed;
    return response.json(todo);
});

app.use((_request, response) => {
    response.status(404).json({ error: 'Rota não encontrada.' });
});

app.listen(port, () => {
    console.log(`Todo API running on port ${port}`);
});
