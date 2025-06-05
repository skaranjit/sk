// cogni_boost/lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../models/game_type.dart'; // Import GameType
import '../models/game_score.dart'; // Import GameScore
import '../services/score_service.dart'; // Import ScoreService
import '../games/sequence_recall_game.dart';
import '../games/tap_the_target_game.dart';
import '../games/pattern_recognition_game.dart'; // New import

class GameScreen extends StatefulWidget {
  final List<GameType> dailyChallengeGames;

  GameScreen({required this.dailyChallengeGames});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentGameIndex = 0;
  Widget? _currentGameWidget; // To hold the current game instance
  late AdHelper _adHelper; // Ensure AdHelper is initialized
  ScoreService _scoreService = ScoreService(); // From previous step
  String _gameTitle = "Game"; // Added state variable for game title

  @override
  void initState() {
    super.initState();
    _adHelper = AdHelper(); // Initialize AdHelper
    _adHelper.loadRewardedAd(); // For SequenceRecallGame
    _adHelper.loadInterstitialAd(); // Load interstitial for end of challenge
    _loadGame();
  }

  @override
  void dispose(){
     _adHelper.dispose(); // Dispose AdHelper
     super.dispose();
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
        Key gameKey = UniqueKey();
        Widget gameWidget;
        switch (currentGameType) {
          case GameType.sequenceRecall:
            gameWidget = SequenceRecallGame(
              key: gameKey,
              onGameCompleted: (score) => _handleGameCompletion(currentGameType, score),
              onGameFlowFinished: _advanceToNextGameOrFinish, // Use the new callback
            );
            break;
          case GameType.tapTheTarget:
            gameWidget = TapTheTargetGame(
              key: gameKey,
              onGameCompleted: (score) => _handleGameCompletion(currentGameType, score),
              onGameFlowFinished: _advanceToNextGameOrFinish, // Use the new callback
            );
            break;
          case GameType.patternRecognition: // New case
            gameWidget = PatternRecognitionGame(
              key: gameKey,
              onGameCompleted: (score) => _handleGameCompletion(currentGameType, score),
              onGameFlowFinished: _advanceToNextGameOrFinish,
            );
            break;
          // default: gameWidget = Center(child: Text("Unknown Game Type: $currentGameType"));
        }
        _currentGameWidget = gameWidget;
        // Update game title
        if (currentGameType == GameType.sequenceRecall) _gameTitle = "Sequence Recall";
        else if (currentGameType == GameType.tapTheTarget) _gameTitle = "Tap The Target";
        else if (currentGameType == GameType.patternRecognition) _gameTitle = "Pattern Recognition";
        else _gameTitle = "Game";

      });
    } else {
      _completeChallengeAndPop(); // Should be called by _advanceToNextGameOrFinish
    }
  }

  void _advanceToNextGameOrFinish() { // Renamed from _onGameFinished for clarity
     if (!mounted) return; // Ensure widget is still mounted

     if (_currentGameIndex < widget.dailyChallengeGames.length - 1) {
         setState(() {
             _currentGameIndex++;
             _loadGame(); // Load the next game
         });
     } else {
         // Last game finished - show interstitial ad then complete challenge
         _adHelper.showInterstitialAd(onAdDismissed: () {
             if(mounted) {
                 _completeChallengeAndPop();
             }
         });
     }
  }

  void _completeChallengeAndPop() async { // Renamed from _completeChallenge
     int newStreak = await _scoreService.updateStreakOnChallengeCompletion(); // Update streak

     // Ensure widget is still mounted before interacting with context
     if (!mounted) return;

     Navigator.of(context).pop(true); // Pop and signal HomeScreen to refresh (true indicates completion)

     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily Challenge Complete! Your streak: $newStreak day(s)!')),
     );
  }

  void _onGameFinished() { // This calls _completeChallenge via ad dismissal
    if (_currentGameIndex < widget.dailyChallengeGames.length - 1) {
      setState(() {
        _currentGameIndex++;
        _loadGame();
      });
    } else {
      // Last game finished - show interstitial ad
      _adHelper.showInterstitialAd(onAdDismissed: () {
         if(mounted) { // Check mounted before calling _completeChallenge
             _completeChallenge();
         }
      });
    }
  }
  // ... rest of _GameScreenState ...
  @override
  Widget build(BuildContext context) {
    if (_currentGameWidget == null && _currentGameIndex >= widget.dailyChallengeGames.length) {
      // This state means challenge is complete and waiting for navigation (e.g. ad dismissed)
      // Or if no games were provided initially.
      return Scaffold(
        appBar: AppBar(title: Text('Daily Challenge')),
        body: Center(child: Text('Challenge complete or loading...')),
      );
    }
     if (_currentGameWidget == null) {
        // Initial loading state or error
        return Scaffold(
            appBar: AppBar(title: Text('Daily Challenge')),
            body: Center(child: CircularProgressIndicator()),
        );
    }


    // Determine the title for the AppBar based on the current game
    // String gameTitle = "Game"; // Removed, using _gameTitle state variable
    // if (_currentGameIndex < widget.dailyChallengeGames.length) {
    //      GameType currentGameType = widget.dailyChallengeGames[_currentGameIndex];
    //      if (currentGameType == GameType.sequenceRecall) gameTitle = "Sequence Recall";
    //      else if (currentGameType == GameType.tapTheTarget) gameTitle = "Tap The Target";
    //      else if (currentGameType == GameType.patternRecognition) gameTitle = "Pattern Recognition";
    // }


    return Scaffold(
      appBar: AppBar(
          title: Text('Daily Challenge: $_gameTitle (${_currentGameIndex + 1}/${widget.dailyChallengeGames.length})'),
          automaticallyImplyLeading: false,
      ),
      body: _currentGameWidget ?? Center(child: Text("Loading game...")), // Display current game directly
      // REMOVE the Column and ElevatedButton for "Finish Game & Next"
    );
  }
}
