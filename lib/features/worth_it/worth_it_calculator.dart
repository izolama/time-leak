import 'worth_it_models.dart';

const double _kWeeksPerMonth = 4.33;

WorthItOutputs calculateWorthIt(WorthItInputs inputs) {
  final workDaysPerMonth = inputs.workDaysPerWeek * _kWeeksPerMonth;
  final commuteHoursPerDay = inputs.commuteMinutesPerDay / 60;
  final breakHoursPerDay = inputs.breakMinutesPerDay / 60;

  final timeCommittedPerDay =
      inputs.workHoursPerDay + commuteHoursPerDay + breakHoursPerDay;
  final workHoursPerMonth = inputs.workHoursPerDay * workDaysPerMonth;
  final commuteHoursPerMonth =
      commuteHoursPerDay * inputs.commuteDaysPerWeek * _kWeeksPerMonth;
  final timeCommittedPerMonth = timeCommittedPerDay * workDaysPerMonth;

  final commuteMinutesPerWorkHour =
      (inputs.commuteMinutesPerDay / inputs.workHoursPerDay).round();

  final hourlyWorkRate =
      workHoursPerMonth == 0 ? 0.0 : inputs.monthlyIncome / workHoursPerMonth;
  final effectiveHourlyRate =
      timeCommittedPerMonth == 0
          ? 0.0
          : inputs.monthlyIncome / timeCommittedPerMonth;

  return WorthItOutputs(
    commuteMinutesPerWorkHour: commuteMinutesPerWorkHour,
    hourlyWorkRate: hourlyWorkRate,
    effectiveHourlyRate: effectiveHourlyRate,
    workHoursPerMonth: workHoursPerMonth,
    commuteHoursPerMonth: commuteHoursPerMonth,
    timeCommittedPerMonth: timeCommittedPerMonth,
  );
}
