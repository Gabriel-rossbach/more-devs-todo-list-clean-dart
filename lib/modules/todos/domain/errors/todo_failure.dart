/// Erro do domínio. As camadas de fora traduzem qualquer falha
/// (rede, banco, parse) para este tipo antes de chegar ao Presenter.
class TodoFailure implements Exception {
  final String message;
  const TodoFailure(this.message);

  @override
  String toString() => 'TodoFailure: $message';
}
