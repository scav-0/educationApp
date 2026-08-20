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

class GamesPerDay {
  final DateTime date;
  final int games;

  GamesPerDay({
    required this.date,
    required this.games,
  });

  factory GamesPerDay.fromJson(Map<String, dynamic> json) {
    return GamesPerDay(
      date: DateTime.parse(json['date']),
      games: int.parse(json['games_played'].toString()),
    );
  }
}