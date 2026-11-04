import 'package:flutter/foundation.dart';

import '../model/habit.dart';
import '../model/habits_service.dart';

class HabitItem {
  const HabitItem({
    required this.id,
    required this.name,
    required this.streakLabel,
    required this.onFire,
    required this.doneToday,
  });

  final int id;
  final String name;
  final String streakLabel;
  final bool onFire;
  final bool doneToday;
}

class HabitsViewModel extends ChangeNotifier {
  HabitsViewModel(this.service);

  final HabitsService service;

  List<Habit> _habits = [];
  bool loading = false;
  String? error;

  DateTime get _today => DateTime.now();

  List<HabitItem> get items {
    final today = _today;
    return _habits.map((habit) {
      final streak = habit.streakOn(today);
      return HabitItem(
        id: habit.id,
        name: habit.name,
        streakLabel: streak > 0
            ? '$streak ${streak == 1 ? 'dia seguido' : 'dias seguidos'}'
            : 'Comece hoje',
        onFire: streak > 0,
        doneToday: habit.isDoneOn(today),
      );
    }).toList();
  }

  int get total => _habits.length;

  int get doneToday => _habits.where((habit) => habit.isDoneOn(_today)).length;

  int get bestStreak {
    final today = _today;
    return _habits.fold(0, (best, habit) {
      final streak = habit.streakOn(today);
      return streak > best ? streak : best;
    });
  }

  double get progress => total == 0 ? 0 : doneToday / total;

  String get bestStreakLabel =>
      '🔥 melhor: $bestStreak ${bestStreak == 1 ? 'dia' : 'dias'}';

  String get remainingLabel => total > 0 && doneToday == total
      ? 'Tudo feito hoje · mandou bem!'
      : 'Faltam ${total - doneToday} para fechar o dia';

  String get todayLabel => _dateLabel(_today);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _habits = await service.fetchAll();
    } catch (_) {
      error = 'Não foi possível carregar os hábitos';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> checkIn(int id) async {
    try {
      final updated = await service.checkIn(id);
      _habits = [
        for (final habit in _habits) habit.id == id ? updated : habit,
      ];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

String _dateLabel(DateTime date) {
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
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}
