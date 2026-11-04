import 'package:dio/dio.dart';

import 'session.dart';

/// E-mail ou senha errados (a API respondeu 401).
class InvalidCredentialsException implements Exception {}

class AuthService {
  AuthService(this.dio);

  final Dio dio;

  Future<Session> login(String email, String password) async {
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return Session.fromMap(res.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw InvalidCredentialsException();
      rethrow;
    }
  }
}
