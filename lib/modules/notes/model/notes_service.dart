import 'package:dio/dio.dart';

import 'note.dart';

/// Parte do Model que conversa com a API. No MVC não há datasource nem
/// repositório separados: o próprio Model busca e salva os dados.
class NotesService {
  NotesService(this.dio);

  final Dio dio;

  Future<List<Note>> fetchAll() async {
    final res = await dio.get<List<dynamic>>('/notes');
    return res.data!.cast<Map<String, dynamic>>().map(Note.fromMap).toList();
  }

  Future<Note> create({required String title, required String content}) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/notes',
      data: {'title': title, 'content': content},
    );
    return Note.fromMap(res.data!);
  }

  Future<Note> update(
    int id, {
    required String title,
    required String content,
  }) async {
    final res = await dio.put<Map<String, dynamic>>(
      '/notes/$id',
      data: {'title': title, 'content': content},
    );
    return Note.fromMap(res.data!);
  }

  Future<void> delete(int id) async {
    await dio.delete<void>('/notes/$id');
  }
}
