class WorthItInputs {
  WorthItInputs({
    required this.monthlyIncome,
    required this.workHoursPerDay,
    required this.workDaysPerWeek,
    required this.commuteMinutesPerDay,
    required this.commuteDaysPerWeek,
    required this.breakMinutesPerDay,
  });

  final int monthlyIncome;
  final double workHoursPerDay;
  final int workDaysPerWeek;
  final int commuteMinutesPerDay;
  final int commuteDaysPerWeek;
  final int breakMinutesPerDay;
}

class WorthItOutputs {
  WorthItOutputs({
    required this.commuteMinutesPerWorkHour,
    required this.hourlyWorkRate,
    required this.effectiveHourlyRate,
    required this.workHoursPerMonth,
    required this.commuteHoursPerMonth,
    required this.timeCommittedPerMonth,
  });

  final int commuteMinutesPerWorkHour;
  final double hourlyWorkRate;
  final double effectiveHourlyRate;
  final double workHoursPerMonth;
  final double commuteHoursPerMonth;
  final double timeCommittedPerMonth;
}
