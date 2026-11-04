import 'package:dio/dio.dart';

import 'habit.dart';

class HabitsService {
  HabitsService(this.dio);

  final Dio dio;

  Future<List<Habit>> fetchAll() async {
    try {
      final res = await dio.get<List<dynamic>>('/habits');
      return res.data!.cast<Map<String, dynamic>>().map(Habit.fromMap).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch habits: $e');
    } on Exception catch (e) {
      throw Exception('Failed to fetch habits: $e');
    }
  }

  Future<Habit> checkIn(int id) async {
    final res = await dio.post<Map<String, dynamic>>('/habits/$id/checkins');
    return Habit.fromMap(res.data!);
  }
}
