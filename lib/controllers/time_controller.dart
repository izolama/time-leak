import 'package:get/get.dart';

import '../models/daily_time_leak.dart';
import '../storage/local_storage.dart';

class TimeAggregationController extends GetxController {
  TimeAggregationController({required this.localStorage});

  final LocalStorage localStorage;

  RxInt todaySeconds = 0.obs;
  RxInt weekSeconds = 0.obs;

  final Map<DateTime, DailyTimeLeak> _records = {};

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> addMovingSeconds(int seconds) async {
    if (seconds <= 0) return;
    final today = _dateOnly(DateTime.now());
    final existing = _records[today];
    final updated = DailyTimeLeak(
      date: today,
      movingSeconds: (existing?.movingSeconds ?? 0) + seconds,
    );
    _records[today] = updated;
    await _persist();
    _recalculate();
  }

  Future<void> _load() async {
    final stored = await localStorage.loadDailyRecords();
    _records
      ..clear()
      ..addAll(stored);
    _recalculate();
  }

  Future<void> _persist() async {
    await localStorage.saveDailyRecords(_records);
  }

  void _recalculate() {
    final today = _dateOnly(DateTime.now());
    todaySeconds.value = _records[today]?.movingSeconds ?? 0;

    final now = DateTime.now();
    final startOfWeek = _dateOnly(
      now.subtract(Duration(days: now.weekday - 1)),
    );
    var weekTotal = 0;
    _records.forEach((date, record) {
      if (!date.isBefore(startOfWeek) && !date.isAfter(today)) {
        weekTotal += record.movingSeconds;
      }
    });
    weekSeconds.value = weekTotal;
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
