import 'package:flutter/foundation.dart';

import '../model/note.dart';
import '../model/notes_service.dart';

/// Controller: recebe os eventos da View, chama o Model e avisa a View
/// (notifyListeners) quando o estado muda.
class NotesController extends ChangeNotifier {
  NotesController(this.service);

  final NotesService service;

  List<Note> notes = [];
  bool loading = false;
  String? error;
  String query = '';

  List<Note> get visibleNotes =>
      notes.where((note) => note.matches(query)).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      notes = await service.fetchAll();
    } catch (_) {
      error = 'Não foi possível carregar as notas';
    }
    loading = false;
    notifyListeners();
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  /// As ações devolvem false se a API falhar; a View decide como avisar.
  Future<bool> create(String title, String content) async {
    try {
      final note = await service.create(title: title, content: content);
      notes = [note, ...notes];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// A nota editada sobe para o topo, igual à ordem que a API devolve.
  Future<bool> update(Note note, String title, String content) async {
    try {
      final updated =
          await service.update(note.id, title: title, content: content);
      notes = [updated, ...notes.where((item) => item.id != note.id)];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(Note note) async {
    try {
      await service.delete(note.id);
      notes = notes.where((item) => item.id != note.id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
