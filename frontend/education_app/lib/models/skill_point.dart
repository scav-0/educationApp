class SkillPoint {
  final double pKnow;
  final DateTime timestamp;

  SkillPoint({
    required this.pKnow,
    required this.timestamp,
  });

  factory SkillPoint.fromJson(
    Map<String, dynamic> json,
  ) {
    return SkillPoint(
      pKnow: double.parse(
        json['p_know'].toString(),
      ),
      timestamp: DateTime.parse(
        json['played_at'],
      ),
    );
  }
}