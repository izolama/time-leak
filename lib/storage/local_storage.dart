import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_time_leak.dart';

class LocalStorage {
  LocalStorage({SharedPreferences? preferences}) : _preferences = preferences;

  static const _dailyKey = 'daily_time_leak';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<Map<DateTime, DailyTimeLeak>> loadDailyRecords() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_dailyKey);
    if (raw == null) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final records = <DateTime, DailyTimeLeak>{};
      decoded.forEach((key, value) {
        final map = Map<String, dynamic>.from(value as Map);
        final record = DailyTimeLeak.fromMap(map);
        records[record.date] = record;
      });
      return records;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDailyRecords(Map<DateTime, DailyTimeLeak> records) async {
    final prefs = await _prefs();
    final serialized = <String, dynamic>{};
    records.forEach((key, value) {
      serialized[key.toIso8601String()] = value.toMap();
    });
    await prefs.setString(_dailyKey, jsonEncode(serialized));
  }
}
