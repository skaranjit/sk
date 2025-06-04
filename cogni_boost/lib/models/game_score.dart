// cogni_boost/lib/models/game_score.dart
import 'game_type.dart';

class GameScore {
  final GameType gameType;
  final int score;
  final DateTime timestamp;

  GameScore({required this.gameType, required this.score, required this.timestamp});

  // For storing in shared_preferences, we'll need to convert to/from JSON or a simple string format.
  // For simplicity in this PoC, we'll store as a list of strings.
  // Example: "sequenceRecall:10:2023-10-27T10:00:00.000Z"
  @override
  String toString() {
    return '${gameType.name}:${score}:${timestamp.toIso8601String()}';
  }

  static GameScore? fromString(String s) {
    try {
      final parts = s.split(':');
      if (parts.length < 3) return null; // Basic validation
      // Handle potential multi-colon issues if game names could have them (not an issue with enum.name)
      final gameName = parts[0];
      final score = int.parse(parts[1]);
      // Reconstruct ISO string if it was split further by mistake, though unlikely with current format
      final timestampString = parts.sublist(2).join(':');
      final timestamp = DateTime.parse(timestampString);

      GameType? gameType;
      for (GameType gt in GameType.values) {
         if (gt.name == gameName) {
             gameType = gt;
             break;
         }
      }
      if (gameType == null) return null;

      return GameScore(gameType: gameType, score: score, timestamp: timestamp);
    } catch (e) {
      print("Error parsing GameScore from string: $s, error: $e");
      return null;
    }
  }
}
