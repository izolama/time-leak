import 'package:get/get.dart';

import '../../storage/local_storage.dart';
import '../../utils/formatters.dart';
import 'worth_it_calculator.dart';
import 'worth_it_models.dart';

class WorthItController extends GetxController {
  WorthItController({LocalStorage? storage})
    : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  RxInt monthlyIncome = 0.obs;
  RxDouble workHoursPerDay = 8.0.obs;
  RxInt workDaysPerWeek = 5.obs;
  RxInt commuteMinutesPerDay = 0.obs;
  RxInt commuteDaysPerWeek = 5.obs;
  RxBool useTimeLeakCommute = true.obs;
  RxInt breakMinutesPerDay = 0.obs;

  RxInt derivedCommuteMinutes = 0.obs;
  RxBool commuteDataAvailable = true.obs;
  RxBool commuteDataLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCommuteFromTimeLeak();
  }

  Future<void> _loadCommuteFromTimeLeak() async {
    commuteDataLoading.value = true;
    final records = await _storage.loadDailyRecords();
    final now = DateTime.now();
    final start = _dateOnly(now).subtract(const Duration(days: 6));

    var totalSeconds = 0;
    var days = 0;

    for (final entry in records.entries) {
      final date = _dateOnly(entry.key);
      if (date.isBefore(start) || date.isAfter(now)) continue;
      if (entry.value.movingSeconds >= 600) {
        totalSeconds += entry.value.movingSeconds;
        days++;
      }
    }

    if (days >= 3) {
      final avgMinutes = (totalSeconds / days / 60).round();
      derivedCommuteMinutes.value = avgMinutes;
      commuteDataAvailable.value = true;
      commuteMinutesPerDay.value = avgMinutes;
    } else {
      derivedCommuteMinutes.value = 0;
      commuteDataAvailable.value = false;
      useTimeLeakCommute.value = false;
    }
    commuteDataLoading.value = false;
  }

  void toggleUseTimeLeakCommute(bool enabled) {
    useTimeLeakCommute.value = enabled;
    if (enabled) {
      _loadCommuteFromTimeLeak();
    }
  }

  int get activeCommuteMinutesPerDay {
    if (useTimeLeakCommute.value && commuteDataAvailable.value) {
      return derivedCommuteMinutes.value;
    }
    return commuteMinutesPerDay.value;
  }

  bool get isValid {
    final incomeValid = monthlyIncome.value > 0;
    final workHoursValid =
        workHoursPerDay.value >= 1 && workHoursPerDay.value <= 16;
    final workDaysValid =
        workDaysPerWeek.value >= 1 && workDaysPerWeek.value <= 7;
    final commuteDaysValid =
        commuteDaysPerWeek.value >= 1 && commuteDaysPerWeek.value <= 7;
    final commuteValid =
        activeCommuteMinutesPerDay >= 0 &&
        activeCommuteMinutesPerDay <= 360 &&
        (!useTimeLeakCommute.value || commuteDataAvailable.value);
    final breakValid =
        breakMinutesPerDay.value >= 0 && breakMinutesPerDay.value <= 360;
    return incomeValid &&
        workHoursValid &&
        workDaysValid &&
        commuteDaysValid &&
        commuteValid &&
        breakValid;
  }

  WorthItOutputs computeOutputs() {
    final inputs = WorthItInputs(
      monthlyIncome: monthlyIncome.value,
      workHoursPerDay: workHoursPerDay.value,
      workDaysPerWeek: workDaysPerWeek.value,
      commuteMinutesPerDay: activeCommuteMinutesPerDay,
      commuteDaysPerWeek: commuteDaysPerWeek.value,
      breakMinutesPerDay: breakMinutesPerDay.value,
    );
    return calculateWorthIt(inputs);
  }

  String formatCurrency(int value) => formatCurrencyIDR(value);

  String formatHours(double value) => formatHoursOneDecimal(value);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
