import 'package:flutter/foundation.dart';

import '../model/auth_service.dart';
import '../model/session.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this.service);

  final AuthService service;

  String _email = '';
  String _password = '';

  bool loading = false;
  bool obscurePassword = true;

  /// Só visual por enquanto: ainda não guarda a sessão entre aberturas.
  bool rememberMe = false;
  String? emailError;
  String? error;
  Session? session;

  bool get loggedIn => session != null;

  bool get canSubmit =>
      !loading && _email.trim().isNotEmpty && _password.isNotEmpty;

  void setEmail(String value) {
    _email = value;
    emailError = null;
    error = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    error = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  Future<void> login() async {
    if (!canSubmit) return;

    final email = _email.trim();
    if (!_emailPattern.hasMatch(email)) {
      emailError = 'Digite um e-mail válido';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();
    try {
      session = await service.login(email, _password);
    } on InvalidCredentialsException {
      error = 'E-mail ou senha incorretos';
    } catch (_) {
      error = 'Não foi possível entrar. Tente de novo.';
    }
    loading = false;
    notifyListeners();
  }
}
