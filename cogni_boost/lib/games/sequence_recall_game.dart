// cogni_boost/lib/games/sequence_recall_game.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/ad_helper.dart';
import '../../services/score_service.dart'; // Import ScoreService

class SequenceRecallGame extends StatefulWidget {
  final Function(int score)? onGameCompleted;
  final Function()? onGameFlowFinished; // New callback

  SequenceRecallGame({Key? key, this.onGameCompleted, this.onGameFlowFinished}) : super(key: key);
  @override
  _SequenceRecallGameState createState() => _SequenceRecallGameState();
}

class _SequenceRecallGameState extends State<SequenceRecallGame> {
  final List<Color> _availableColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
  List<Color> _gameSequence = [];
  List<Color> _playerSequence = [];
  String _message = "Memorize the sequence";
  bool _isPlayingSequence = false;
  bool _isPlayerTurn = false;
  late AdHelper _adHelper;
  bool _canRetryWithAd = false;
  bool _usedRetryWithAdThisTurn = false;

  int _currentLevel = 1;
  int _consecutiveSuccesses = 0;
  final ScoreService _scoreService = ScoreService();
  bool _isLoadingDifficulty = true;

  @override
  void initState() {
    super.initState();
    _adHelper = AdHelper();
    _adHelper.loadRewardedAd();
    _loadDifficultyAndStartGame();
  }

  Future<void> _loadDifficultyAndStartGame() async {
    setState(() { _isLoadingDifficulty = true; });
    Map<String, int> difficultyData = await _scoreService.getSequenceRecallDifficulty();
    if(mounted) {
         setState(() {
             _currentLevel = difficultyData['level']!;
             _consecutiveSuccesses = difficultyData['consecutiveSuccesses']!;
             _isLoadingDifficulty = false;
         });
         _startGameLogic();
    }
  }

  void _startGameLogic(){
     _message = "Level $_currentLevel. Memorize...";
     _playerSequence.clear();
     _generateSequence();
     _playSequence();
  }

  @override
  void dispose() {
     _adHelper.dispose();
     super.dispose();
  }

  void _generateSequence() {
    _gameSequence.clear();
    Random random = Random();
    for (int i = 0; i < _currentLevel + 1; i++) {
      _gameSequence.add(_availableColors[random.nextInt(_availableColors.length)]);
    }
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlayingSequence = true;
      _isPlayerTurn = false;
      _playerSequence.clear();
      // Message is set in _startGameLogic or _endGame
    });

    await Future.delayed(Duration(milliseconds: 500)); // Initial pause

    for (Color color in _gameSequence) {
      setState(() { _message = "Displaying: ${color.toString().split('.').last}"; });
      await Future.delayed(Duration(milliseconds: 700 - (_currentLevel * 30).clamp(0, 500).toInt())); // Faster with level
      setState(() { _message = "Level $_currentLevel. Memorize..."; });
      await Future.delayed(Duration(milliseconds: 150 - (_currentLevel * 10).clamp(0,100).toInt()));
    }

    setState(() {
      _isPlayingSequence = false;
      _isPlayerTurn = true;
      _message = "Level $_currentLevel. Your turn!";
    });
  }

  void _onColorTapped(Color color) {
    if (!_isPlayerTurn || _isPlayingSequence) return;

    if (_isPlayerTurn && _canRetryWithAd) {
         setState(() { _canRetryWithAd = false; });
    }

    setState(() { _playerSequence.add(color); });

    for (int i = 0; i < _playerSequence.length; i++) {
      if (_playerSequence[i] != _gameSequence[i]) {
        _endGame(false);
        return;
      }
    }

    if (_playerSequence.length == _gameSequence.length) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    bool canTriggerFlowFinish = false;

    if (success) {
      _consecutiveSuccesses++;
      int score = _currentLevel * 10 + _consecutiveSuccesses * 2;
      widget.onGameCompleted?.call(score);

      if (_consecutiveSuccesses >= 2) {
        _currentLevel = (_currentLevel < 10) ? _currentLevel + 1 : 10;
        _consecutiveSuccesses = 0;
        _message = "Level Up! Now Level $_currentLevel. Score: $score";
      } else {
        _message = "Correct! Level: $_currentLevel. Score: $score. Consecutive: $_consecutiveSuccesses/2";
      }
      _usedRetryWithAdThisTurn = false;
      _canRetryWithAd = false;
      canTriggerFlowFinish = true;

    } else {
      if (!_usedRetryWithAdThisTurn) {
        _message = "Incorrect! Watch an ad for an extra try at Level $_currentLevel?";
        _canRetryWithAd = true;
        setState(() { _isPlayerTurn = false; });
        // Save difficulty here because if user quits without watching ad, current state is saved.
        _scoreService.saveSequenceRecallDifficulty(_currentLevel, _consecutiveSuccesses);
        // No flow finish yet, ad is offered.
        return;
      } else {
         _currentLevel = (_currentLevel > 1) ? _currentLevel - 1 : 1;
         _consecutiveSuccesses = 0;
         _message = "Incorrect. Level dropped to $_currentLevel. Sequence: ${_gameSequence.map((c)=>c.toString().split('.').last).join(', ')}";
         _canRetryWithAd = false;
         canTriggerFlowFinish = true;
      }
    }

    _scoreService.saveSequenceRecallDifficulty(_currentLevel, _consecutiveSuccesses);

    if (canTriggerFlowFinish) {
      print("SequenceRecallGame: Triggering onGameFlowFinished.");
      widget.onGameFlowFinished?.call();
    }

    setState(() {
      _isPlayerTurn = false;
      if (canTriggerFlowFinish) { // Reset ad flags if game truly ended for this turn
         _usedRetryWithAdThisTurn = false;
         _canRetryWithAd = false;
      }
    });
  }

  void _attemptAdRetry() {
    if (_canRetryWithAd) {
      _adHelper.showRewardedAd(() {
        if(mounted){
            setState(() {
              _message = "Ad watched! Try Level $_currentLevel again.";
              _playerSequence.clear();
              _isPlayerTurn = true; // Player gets another turn
              _canRetryWithAd = false;
              _usedRetryWithAdThisTurn = true;
            });
            // IMPORTANT: DO NOT call onGameFlowFinished here. The game continues.
        }
      });
    }
  }

  void _restartGame() {
     // This button is mainly for practice mode (when onGameFlowFinished is null)
     // or if a specific "restart this level" button is desired in flow mode (less common).
     if(mounted){
         setState(() {
             _isLoadingDifficulty = true;
         });
         _loadDifficultyAndStartGame(); // Reloads current saved difficulty and starts
     }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDifficulty) {
      return Scaffold(
        appBar: AppBar(title: Text('Sequence Recall')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Sequence Recall - Level $_currentLevel')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_message, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          if (_isPlayingSequence)
             Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text("Watch carefully...", style: TextStyle(fontSize:16, color: Theme.of(context).hintColor)),
             ),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _availableColors.map((color) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: Size(80, 80)),
                onPressed: () => _onColorTapped(color),
                child: null,
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          // Button logic: Show "Play Again" if not in a flow or if game is over (no ad pending)
          // If in a flow (widget.onGameFlowFinished != null), this button might be hidden
          // as flow is handled by onGameFlowFinished callback.
          // For PoC, let's assume if onGameFlowFinished is present, GameScreen controls "next".
          // So this button is for practice mode, or if the game explicitly ends AND is not in a flow.
          if (!_isPlayingSequence && !_isPlayerTurn && !_canRetryWithAd && widget.onGameFlowFinished == null)
             ElevatedButton(onPressed: _restartGame, child: Text('Play Again')),

          if (_canRetryWithAd) // Ad retry button
             ElevatedButton(
                 onPressed: _attemptAdRetry,
                 child: Text('Watch Ad for Extra Try'),
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
             ),
         SizedBox(height: 10),
         if (!_isPlayingSequence && !_isPlayerTurn)
            Text("Consecutive correct at this level: $_consecutiveSuccesses / 2", style: TextStyle(fontSize: 14.0)),
        ],
      ),
    );
  }
}
