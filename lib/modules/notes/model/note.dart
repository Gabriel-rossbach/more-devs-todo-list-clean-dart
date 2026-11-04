/// Model: os dados de uma nota e as regras sobre eles.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String content;
  final DateTime updatedAt;

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int,
        title: map['title'] as String,
        content: map['content'] as String? ?? '',
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  /// Regra de busca: o termo aparece no título ou no texto, sem diferenciar
  /// maiúsculas. Busca vazia encontra tudo.
  bool matches(String query) {
    final term = query.trim().toLowerCase();
    return term.isEmpty ||
        title.toLowerCase().contains(term) ||
        content.toLowerCase().contains(term);
  }
}
