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
        description: 'API para listar e atualizar tarefas e hábitos.',
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
        '/habits': {
            get: {
                summary: 'Lista os hábitos com o histórico de check-ins',
                responses: {
                    200: {
                        description: 'Lista de hábitos',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'array',
                                    items: { $ref: '#/components/schemas/Habit' },
                                },
                            },
                        },
                    },
                },
            },
        },
        '/habits/{id}/checkins': {
            post: {
                summary: 'Registra o check-in de hoje (fuso de Brasília)',
                parameters: [{
                    name: 'id',
                    in: 'path',
                    required: true,
                    schema: { type: 'integer', example: 1 },
                }],
                responses: {
                    201: {
                        description: 'Check-in registrado',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Habit' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    404: { description: 'Hábito não encontrado' },
                    409: { description: 'Check-in de hoje já registrado' },
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
            Habit: {
                type: 'object',
                required: ['id', 'name', 'checkins'],
                properties: {
                    id: { type: 'integer', example: 1 },
                    name: { type: 'string', example: 'Beber 2L de água' },
                    checkins: {
                        type: 'array',
                        description: 'Datas (AAAA-MM-DD) em ordem crescente',
                        items: { type: 'string', format: 'date', example: '2026-10-27' },
                    },
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

// Data de hoje (AAAA-MM-DD) no fuso de Brasília, para bater com o app.
const today = () =>
    new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Sao_Paulo' }).format(new Date());

const daysAgo = (days) => {
    const date = new Date(`${today()}T00:00:00Z`);
    date.setUTCDate(date.getUTCDate() - days);
    return date.toISOString().slice(0, 10);
};

const seedCheckins = (...days) => days.sort((a, b) => b - a).map(daysAgo);

let habits = [
    { id: 1, name: 'Beber 2L de água', checkins: seedCheckins(1, 2, 3, 4, 5) },
    { id: 2, name: 'Ler 10 páginas', checkins: seedCheckins(0, 1, 2) },
    { id: 3, name: 'Estudar Flutter', checkins: seedCheckins(1, 2, 4, 5, 6) },
    { id: 4, name: 'Caminhar 20 minutos', checkins: [] },
    { id: 5, name: 'Meditar', checkins: seedCheckins(3, 4) },
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

app.get('/habits', (_request, response) => {
    response.json(habits);
});

app.post('/habits/:id/checkins', (request, response) => {
    const id = Number(request.params.id);

    if (!Number.isInteger(id)) {
        return response.status(400).json({ error: 'O id deve ser um número inteiro.' });
    }

    const habit = habits.find((item) => item.id === id);
    if (!habit) {
        return response.status(404).json({ error: 'Hábito não encontrado.' });
    }

    const date = today();
    if (habit.checkins.includes(date)) {
        return response.status(409).json({ error: 'Check-in de hoje já registrado.' });
    }

    habit.checkins.push(date);
    return response.status(201).json(habit);
});

app.use((_request, response) => {
    response.status(404).json({ error: 'Rota não encontrada.' });
});

app.listen(port, () => {
    console.log(`Todo API running on port ${port}`);
});
