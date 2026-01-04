class MeaningEquivalent {
  MeaningEquivalent({
    required this.label,
    required this.secondsPerUnit,
    this.emoji = '',
  });

  final String label;
  final int secondsPerUnit;
  final String emoji;
}

class MeaningDisplay {
  MeaningDisplay({
    required this.emoji,
    required this.label,
    required this.approxUnits,
  });

  final String emoji;
  final String label;
  final int approxUnits;
}
