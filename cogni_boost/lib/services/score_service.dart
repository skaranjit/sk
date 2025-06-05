// cogni_boost/lib/services/score_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_score.dart';
// No need to import GameType here if we use string keys like "sequenceRecallDifficulty"

class ScoreService {
  static const String _scoresKey = 'game_scores';
  // New keys for Sequence Recall difficulty
  static const String _sqRecallLevelKey = 'sequenceRecall_currentLevel';
  static const String _sqRecallConsecutiveSuccessKey = 'sequenceRecall_consecutiveSuccesses';
  static const String _lastCompletionDateKey = 'lastChallengeCompletionDate';
  static const String _currentStreakKey = 'currentStreakCount';

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

  // --- Methods for Sequence Recall Difficulty ---
  Future<void> saveSequenceRecallDifficulty(int level, int consecutiveSuccesses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sqRecallLevelKey, level);
    await prefs.setInt(_sqRecallConsecutiveSuccessKey, consecutiveSuccesses);
    print("Saved SQ Recall Difficulty: Level $level, Successes $consecutiveSuccesses");
  }

  Future<Map<String, int>> getSequenceRecallDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt(_sqRecallLevelKey) ?? 1; // Default to level 1
    int consecutiveSuccesses = prefs.getInt(_sqRecallConsecutiveSuccessKey) ?? 0; // Default to 0
    print("Loaded SQ Recall Difficulty: Level $level, Successes $consecutiveSuccesses");
    return {'level': level, 'consecutiveSuccesses': consecutiveSuccesses};
  }

  // --- Methods for Daily Streaks ---
  Future<Map<String, dynamic>> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastCompletionDateStr = prefs.getString(_lastCompletionDateKey);
    int streakCount = prefs.getInt(_currentStreakKey) ?? 0;
    return {
      'lastCompletionDate': lastCompletionDateStr,
      'streakCount': streakCount,
    };
  }

  Future<int> updateStreakOnChallengeCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastCompletionDateStr = prefs.getString(_lastCompletionDateKey);
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;

    DateTime today = DateTime.now();
    // Normalize today to just YYYY-MM-DD for comparison and storage
    String todayDateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    if (lastCompletionDateStr == todayDateStr) {
      // Challenge already completed today, streak doesn't change further for today.
      print("Streak: Challenge already completed today. Streak remains $currentStreak.");
      return currentStreak;
    }

    DateTime? lastCompletionDate;
    if (lastCompletionDateStr != null) {
      try {
        lastCompletionDate = DateTime.parse(lastCompletionDateStr); // Assumes YYYY-MM-DD format
      } catch (e) {
        print("Error parsing lastCompletionDate: $e");
        lastCompletionDate = null; // Treat as no valid last date
      }
    }

    DateTime yesterday = today.subtract(Duration(days: 1));
    String yesterdayDateStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";


    if (lastCompletionDateStr == yesterdayDateStr) {
      // Last completion was yesterday, increment streak
      currentStreak++;
      print("Streak: Incremented to $currentStreak.");
    } else {
      // Not yesterday (or first time), reset streak to 1
      currentStreak = 1;
      print("Streak: Reset to $currentStreak.");
    }

    await prefs.setString(_lastCompletionDateKey, todayDateStr);
    await prefs.setInt(_currentStreakKey, currentStreak);

    return currentStreak;
  }
}
