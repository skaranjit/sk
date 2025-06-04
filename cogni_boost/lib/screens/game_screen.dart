// cogni_boost/lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../models/game_type.dart'; // Import GameType
import '../models/game_score.dart'; // Import GameScore
import '../services/score_service.dart'; // Import ScoreService
import '../games/sequence_recall_game.dart';
import '../games/tap_the_target_game.dart';

class GameScreen extends StatefulWidget {
  final List<GameType> dailyChallengeGames;

  GameScreen({required this.dailyChallengeGames});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentGameIndex = 0;
  Widget? _currentGameWidget; // To hold the current game instance
  ScoreService _scoreService = ScoreService(); // Add instance

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  void _handleGameCompletion(GameType gameType, int score) {
    _scoreService.addScore(GameScore(gameType: gameType, score: score, timestamp: DateTime.now()));
    // Note: The _onGameFinished button is still manual.
    // In a more refined version, onGameCompleted might also trigger _onGameFinished.
  }

  void _loadGame() {
    if (_currentGameIndex < widget.dailyChallengeGames.length) {
      GameType currentGameType = widget.dailyChallengeGames[_currentGameIndex];
      setState(() {
        // Important: Create a new key for each game instance if they are stateful
        // to ensure their state resets if the same game type appears multiple times.
        Key gameKey = UniqueKey();
        switch (currentGameType) {
          case GameType.sequenceRecall:
            _currentGameWidget = SequenceRecallGame(
              key: gameKey,
              onGameCompleted: (score) => _handleGameCompletion(currentGameType, score),
            );
            break;
          case GameType.tapTheTarget:
            _currentGameWidget = TapTheTargetGame(
              key: gameKey,
              onGameCompleted: (score) => _handleGameCompletion(currentGameType, score),
            );
            break;
          // Add other games here
        }
      });
    } else {
    } else {
      // All games finished
      setState(() {
        _currentGameWidget = null; // Or a summary screen
      });
    }
  }

  void _onGameFinished() { // This would be called by the game itself ideally, or by a button here
    if (_currentGameIndex < widget.dailyChallengeGames.length - 1) {
      setState(() {
        _currentGameIndex++;
        _loadGame();
      });
    } else {
      // Last game finished
      Navigator.of(context).pop(); // Go back to HomeScreen
      // Optionally, show a "Challenge Complete" dialog first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily Challenge Complete!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGameWidget == null) {
      // This case is after all games are finished and _onGameFinished has popped.
      // Or, if no games were provided.
      return Scaffold(
        appBar: AppBar(title: Text('Daily Challenge')),
        body: Center(
          child: Text('Challenge complete or no games loaded.'),
        ),
      );
    }

    // Determine the title for the AppBar based on the current game
    String gameTitle = "Game";
    if (_currentGameIndex < widget.dailyChallengeGames.length) {
         GameType currentGameType = widget.dailyChallengeGames[_currentGameIndex];
         if (currentGameType == GameType.sequenceRecall) gameTitle = "Sequence Recall";
         if (currentGameType == GameType.tapTheTarget) gameTitle = "Tap The Target";
    }


    return Scaffold(
      // We don't want nested Scaffolds if games provide their own.
      // The games (SequenceRecallGame, TapTheTargetGame) already have Scaffolds.
      // So, GameScreen should just return the _currentGameWidget directly.
      // However, we need a way to trigger _onGameFinished.
      // For PoC, let's wrap the game in a Column with a "Next Game" button.
      // A better approach would be for games to have an onComplete callback.
      appBar: AppBar(
          title: Text('Daily Challenge: $gameTitle (${_currentGameIndex + 1}/${widget.dailyChallengeGames.length})'),
          automaticallyImplyLeading: false, // Disable back button for challenge flow
      ),
      body: Column(
        children: [
          Expanded(child: _currentGameWidget!), // The game widget itself
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onGameFinished,
              child: Text(_currentGameIndex < widget.dailyChallengeGames.length - 1 ? 'Finish Game & Next' : 'Finish Challenge'),
            ),
          )
        ],
      )
    );
  }
}
