class DailyTimeLeak {
  DailyTimeLeak({required this.date, required this.movingSeconds});

  final DateTime date;
  final int movingSeconds;

  DailyTimeLeak copyWith({DateTime? date, int? movingSeconds}) {
    return DailyTimeLeak(
      date: date ?? this.date,
      movingSeconds: movingSeconds ?? this.movingSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': _dateOnly(date).toIso8601String(),
      'movingSeconds': movingSeconds,
    };
  }

  factory DailyTimeLeak.fromMap(Map<String, dynamic> map) {
    return DailyTimeLeak(
      date: DateTime.parse(map['date'] as String),
      movingSeconds: map['movingSeconds'] as int,
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
