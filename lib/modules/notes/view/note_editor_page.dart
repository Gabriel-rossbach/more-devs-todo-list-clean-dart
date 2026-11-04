import 'package:flutter/material.dart';

/// O que a [NoteEditorPage] devolve ao salvar.
typedef NoteEditorResult = ({String title, String content});

/// Tela para criar ou editar uma nota. Não salva nada sozinha: ao tocar em
/// "Salvar", fecha e devolve o título e o texto para quem abriu a tela.
///
/// Sem [title] é uma nota nova; com [title] é uma edição.
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.title, this.content});

  final String? title;
  final String? content;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final titleController = TextEditingController(text: widget.title);
  late final contentController = TextEditingController(text: widget.content);

  bool get isNew => widget.title == null;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _save() {
    final NoteEditorResult result = (
      title: titleController.text.trim(),
      content: contentController.text,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(isNew ? 'Nova nota' : 'Editar nota'),
        actions: [
          ListenableBuilder(
            listenable: titleController,
            builder: (context, _) => TextButton(
              onPressed: titleController.text.trim().isEmpty ? null : _save,
              child: const Text(
                'Salvar',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                autofocus: isNew,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  hintText: 'Título',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLength: 2000,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'Escreva sua nota...',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
