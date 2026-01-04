String formatCurrencyIDR(int value) {
  final buffer = StringBuffer();
  final digits = value.abs().toString();
  for (int i = 0; i < digits.length; i++) {
    final positionFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  final formatted = buffer.toString();
  return value < 0 ? '-Rp $formatted' : 'Rp $formatted';
}

String formatHoursOneDecimal(double hours) {
  return '${hours.toStringAsFixed(1)}h';
}

String formatHHMM(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}
