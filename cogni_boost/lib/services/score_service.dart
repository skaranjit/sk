// cogni_boost/lib/services/score_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_score.dart';

class ScoreService {
  static const String _scoresKey = 'game_scores';

  Future<void> addScore(GameScore gameScore) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList(_scoresKey) ?? [];
    scores.add(gameScore.toString());
    // Optional: Limit the number of stored scores
    // if (scores.length > 50) {
    //   scores = scores.sublist(scores.length - 50);
    // }
    await prefs.setStringList(_scoresKey, scores);
  }

  Future<List<GameScore>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scoreStrings = prefs.getStringList(_scoresKey) ?? [];
    return scoreStrings
        .map((s) => GameScore.fromString(s))
        .where((gs) => gs != null)
        .cast<GameScore>() // Ensure correct type after filtering nulls
        .toList();
  }
}
