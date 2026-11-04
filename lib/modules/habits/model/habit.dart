class Habit {
  Habit({
    required this.id,
    required this.name,
    required Iterable<DateTime> checkins,
  }) : checkins = {for (final date in checkins) _day(date)};

  final int id;
  final String name;

  final Set<DateTime> checkins;

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as int,
        name: map['name'] as String,
        checkins: (map['checkins'] as List<dynamic>)
            .cast<String>()
            .map(DateTime.parse),
      );

  bool isDoneOn(DateTime day) => checkins.contains(_day(day));

  int streakOn(DateTime today) {
    var day = _day(today);
    if (!checkins.contains(day)) day = _previous(day);
    var streak = 0;
    while (checkins.contains(day)) {
      streak++;
      day = _previous(day);
    }
    return streak;
  }
}

DateTime _day(DateTime date) => DateTime.utc(date.year, date.month, date.day);

DateTime _previous(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day - 1);
