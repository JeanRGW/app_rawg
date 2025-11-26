String idColumn = "id";
String gameIdColumn = "gameId";
String platformColumn = "playedPlatform";
String progressStatusColumn = "progressStatus";
String hoursPlayedColumn = "hoursPlayed";
String recommendedColumn = "recommended";
String scoreVisualColumn = "scoreVisual";
String scoreGameplayColumn = "scoreGameplay";
String scoreNarrativeColumn = "scoreNarrative";
String commentColumn = "comment";

String gameReviewTable = "gameReviewTable";

enum GameProgress {
  planning(0, "Planeja Jogar"),
  playing(1, "Jogando"),
  paused(2, "Pausado"),
  dropped(3, "Abandonado"),
  finished(4, "Finalizado");

  final int id;
  final String label;

  const GameProgress(this.id, this.label);

  static GameProgress fromId(int id) {
    return GameProgress.values.firstWhere(
      (e) => e.id == id,
      orElse: () => GameProgress.planning,
    );
  }
}

class Review {
  Review({
    this.id,
    required this.gameId,
    required this.playedPlatform,
    required this.progressStatus,
    required this.hoursPlayed,
    required this.recommended,
    required this.scoreVisual,
    required this.scoreGameplay,
    required this.scoreNarrative,
    this.comment,
  });

  int? id;
  int gameId;
  int playedPlatform;
  GameProgress progressStatus;
  double hoursPlayed;
  bool recommended;
  int scoreVisual;
  int scoreGameplay;
  int scoreNarrative;
  String? comment;

  Review.fromMap(Map<String, dynamic> map)
    : id = map[idColumn],
      gameId = map[gameIdColumn],
      playedPlatform = map[platformColumn],
      progressStatus = GameProgress.fromId(map[progressStatusColumn]),
      hoursPlayed = map[hoursPlayedColumn].toDouble(),
      recommended = map[recommendedColumn] == 1,
      scoreVisual = map[scoreVisualColumn],
      scoreGameplay = map[scoreGameplayColumn],
      scoreNarrative = map[scoreNarrativeColumn],
      comment = map[commentColumn];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      gameIdColumn: gameId,
      platformColumn: playedPlatform,
      progressStatusColumn: progressStatus.id,
      hoursPlayedColumn: hoursPlayed,
      recommendedColumn: recommended ? 1 : 0,
      scoreVisualColumn: scoreVisual,
      scoreGameplayColumn: scoreGameplay,
      scoreNarrativeColumn: scoreNarrative,
      commentColumn: comment,
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Review("
        "id: $id, "
        "gameId: $gameId, "
        "platform: $playedPlatform, "
        "progress: ${progressStatus.label}, "
        "hoursPlayed: $hoursPlayed, "
        "recommended: $recommended, "
        "visualScore: $scoreVisual, "
        "gameplayScore: $scoreGameplay, "
        "narrativeScore: $scoreNarrative, "
        "comment: $comment"
        ")";
  }
}
