import 'package:flutter/material.dart';

import '../controller/notes_controller.dart';
import '../model/note.dart';
import 'note_editor_page.dart';

/// View: só desenha o estado do controller e repassa os eventos para ele.
class NotesPage extends StatefulWidget {
  const NotesPage({super.key, required this.controller});

  final NotesController controller;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Fica no State para o texto da busca sobreviver ao recarregar a lista.
  final _search = TextEditingController();

  NotesController get controller => widget.controller;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _create() async {
    final result = await Navigator.of(context).push<NoteEditorResult>(
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );
    if (result == null) return;
    final saved = await controller.create(result.title, result.content);
    if (!saved && mounted) _showError('Não foi possível salvar a nota');
  }

  Future<void> _edit(Note note) async {
    final result = await Navigator.of(context).push<NoteEditorResult>(
      MaterialPageRoute(
        builder: (_) =>
            NoteEditorPage(title: note.title, content: note.content),
      ),
    );
    if (result == null) return;
    final saved = await controller.update(note, result.title, result.content);
    if (!saved && mounted) _showError('Não foi possível salvar a nota');
  }

  /// Usado no confirmDismiss: true tira o card da tela, false devolve ele.
  Future<bool> _delete(Note note) async {
    if (!await _confirmDelete(context)) return false;
    final deleted = await controller.delete(note);
    if (!deleted && mounted) _showError('Não foi possível excluir a nota');
    return deleted;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF315CFF),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        ),
        child: Scaffold(
          body: SafeArea(child: _buildBody(context)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _create,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova nota'),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = controller.error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.load,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }

    final notes = controller.visibleNotes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _todayLabel(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Minhas notas',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Atualizar notas',
              onPressed: controller.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _search,
          onChanged: controller.search,
          decoration: InputDecoration(
            hintText: 'Buscar nas notas',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE6E6EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE6E6EA)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${notes.length} ${notes.length == 1 ? 'NOTA' : 'NOTAS'}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        if (notes.isEmpty)
          _EmptyState(searching: controller.query.trim().isNotEmpty)
        else
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(note.id),
                direction: DismissDirection.endToStart,
                background: const _DeleteBackground(),
                confirmDismiss: (_) => _delete(note),
                child: _NoteCard(
                  title: note.title,
                  content: note.content,
                  updatedAt: note.updatedAt,
                  onTap: () => _edit(note),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<bool> _confirmDelete(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir nota?'),
      content: const Text('Essa ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.onTap,
  });

  final String title;
  final String content;
  final DateTime updatedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'editada ${_editedLabel(updatedAt)}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE03131)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            searching ? Icons.search_off_rounded : Icons.sticky_note_2_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            searching ? 'Nada encontrado' : 'Nenhuma nota por aqui',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(searching
              ? 'Tente buscar outra palavra.'
              : 'Toque em "Nova nota" para começar.'),
        ],
      ),
    );
  }
}

/// "agora", "há 5 min", "há 3 h", "ontem", "há 4 dias" ou "dd/mm".
String _editedLabel(DateTime updatedAt) {
  final diff = DateTime.now().difference(updatedAt);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'há ${diff.inHours} h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7) return 'há ${diff.inDays} dias';
  final local = updatedAt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'em ${two(local.day)}/${two(local.month)}';
}

String _todayLabel() {
  const weekdays = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  final now = DateTime.now();
  return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
}
