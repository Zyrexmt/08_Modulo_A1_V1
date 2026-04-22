class RankingEntry {
  final String playerName;
  final int score;

  RankingEntry({required this.playerName, required this.score});

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'score': score,
  };

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      RankingEntry(
        playerName: json['playerName'],
        score: json['score'],
      );
}
