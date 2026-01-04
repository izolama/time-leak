import '../models/daily_time_leak.dart';
import '../storage/local_storage.dart';
import 'meaning_model.dart';

class MeaningService {
  MeaningService({LocalStorage? storage})
    : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  // Static conversion table — symbolic, not scientific.
  final List<MeaningEquivalent> _equivalents = [
    MeaningEquivalent(emoji: '📚', label: 'books', secondsPerUnit: 5 * 3600),
    MeaningEquivalent(
      emoji: '🎸',
      label: 'months of guitar practice',
      secondsPerUnit: 30 * 3600,
    ),
    MeaningEquivalent(
      emoji: '😴',
      label: 'hours of deep rest',
      secondsPerUnit: 8 * 3600,
    ),
    MeaningEquivalent(
      emoji: '🧘',
      label: 'days on a meditation retreat',
      secondsPerUnit: 7 * 24 * 3600,
    ),
    MeaningEquivalent(
      emoji: '🌲',
      label: 'walks in nature',
      secondsPerUnit: 2 * 3600,
    ),
  ];

  Future<int> loadMonthlySeconds() async {
    final records = await _storage.loadDailyRecords();
    if (records.isEmpty) return 0;

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 30));

    var total = 0;
    records.forEach((date, record) {
      if (!date.isBefore(start) && !date.isAfter(now)) {
        total += record.movingSeconds;
      }
    });

    return total;
  }

  List<MeaningDisplay> buildMeaning(int monthlySeconds) {
    if (monthlySeconds <= 0) return [];

    final displays = <MeaningDisplay>[];
    for (final equivalent in _equivalents) {
      final approx = (monthlySeconds / equivalent.secondsPerUnit).round();
      if (approx <= 0) continue;
      displays.add(
        MeaningDisplay(
          emoji: equivalent.emoji,
          label: equivalent.label,
          approxUnits: approx,
        ),
      );
      if (displays.length >= 3) break;
    }
    return displays;
  }
}
