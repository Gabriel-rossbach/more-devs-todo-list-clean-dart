const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

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
