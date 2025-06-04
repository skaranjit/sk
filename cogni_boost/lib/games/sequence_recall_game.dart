// cogni_boost/lib/games/sequence_recall_game.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/ad_helper.dart'; // Import AdHelper

class SequenceRecallGame extends StatefulWidget {
  final Function(int score)? onGameCompleted; // Add this
  SequenceRecallGame({Key? key, this.onGameCompleted}) : super(key: key);
  @override
  _SequenceRecallGameState createState() => _SequenceRecallGameState();
}

class _SequenceRecallGameState extends State<SequenceRecallGame> {
  final List<Color> _availableColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
  List<Color> _gameSequence = [];
  List<Color> _playerSequence = [];
  int _currentLevel = 1;
  String _message = "Memorize the sequence";
  bool _isPlayingSequence = false;
  bool _isPlayerTurn = false;
  late AdHelper _adHelper;
  bool _canRetryWithAd = false;
  bool _usedRetryWithAdThisTurn = false; // To ensure only one ad retry per mistake

  @override
  void initState() {
    super.initState();
    _adHelper = AdHelper();
    _adHelper.loadRewardedAd(); // Load ad on init
    _generateSequence();
    _playSequence();
  }

  @override
  void dispose() {
     _adHelper.dispose(); // Dispose ad helper
     super.dispose();
  }

  void _generateSequence() {
    _gameSequence.clear();
    Random random = Random();
    for (int i = 0; i < _currentLevel + 1; i++) { // Sequence length starts at 2
      _gameSequence.add(_availableColors[random.nextInt(_availableColors.length)]);
    }
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlayingSequence = true;
      _isPlayerTurn = false;
      _playerSequence.clear();
      _message = "Watch carefully...";
    });

    for (Color color in _gameSequence) {
      // For PoC, just a delay. In a real game, you'd flash a color.
      // This state change is just to illustrate the phase.
      setState(() { _message = "Displaying: ${color.toString()}"; });
      await Future.delayed(Duration(milliseconds: 800)); // Time the color is shown
      setState(() { _message = "Watch carefully..."; });
      await Future.delayed(Duration(milliseconds: 200)); // Pause between colors
    }

    setState(() {
      _isPlayingSequence = false;
      _isPlayerTurn = true;
      _message = "Your turn! Tap the sequence.";
    });
  }

  void _onColorTapped(Color color) {
    if (!_isPlayerTurn || _isPlayingSequence) return;

    // Ensure _canRetryWithAd is false when player starts tapping
    if (_isPlayerTurn && _canRetryWithAd) {
         setState(() {
             _canRetryWithAd = false;
         });
    }

    setState(() {
      _playerSequence.add(color);
    });

    // Check if player's input is correct so far
    for (int i = 0; i < _playerSequence.length; i++) {
      if (_playerSequence[i] != _gameSequence[i]) {
        _endGame(false);
        return;
      }
    }

    // Check if sequence is complete
    if (_playerSequence.length == _gameSequence.length) {
      _endGame(true);
    }
  }

  void _endGame(bool success) {
    setState(() {
      _isPlayerTurn = false;
      if (success) {
        int score = _currentLevel * 10;
        _message = "Correct! Well done! Score: $score";
        widget.onGameCompleted?.call(score);
        _usedRetryWithAdThisTurn = false; // Reset for next level/game
        _canRetryWithAd = false;
      } else {
        if (!_usedRetryWithAdThisTurn) {
          _message = "Incorrect! Watch an ad for an extra try?";
          _canRetryWithAd = true; // Offer ad retry
        } else {
          _message = "Incorrect! Game Over. The sequence was ${_gameSequence.map((c)=>c.toString().split('.').last).join(', ')}";
          _canRetryWithAd = false;
        }
      }
    });
  }

  void _attemptAdRetry() {
    if (_canRetryWithAd) {
      _adHelper.showRewardedAd(() {
        // User earned reward
        setState(() {
          _message = "Ad watched! Try the sequence again.";
          _playerSequence.clear();
          _isPlayerTurn = true;
          _canRetryWithAd = false;
          _usedRetryWithAdThisTurn = true; // Mark ad as used for this specific mistake
          // Do not re-play sequence, user has to remember it from before
        });
      });
    }
  }

  void _restartGame({bool nextLevel = false}) { // Modified restart
     if(nextLevel) {
         _currentLevel++;
     }
     setState(() {
         _usedRetryWithAdThisTurn = false; // Reset ad usage status
         _canRetryWithAd = false;
         _playerSequence.clear();
     });
     _generateSequence();
     _playSequence(); // This already sets messages and player turn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sequence Recall')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_message, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          if (_isPlayingSequence)
             Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text("Current Sequence Item (Conceptual): ${_gameSequence.isNotEmpty && _playerSequence.length < _gameSequence.length ? _gameSequence[_playerSequence.length].toString().split('.').last : ''}", style: TextStyle(fontSize:16)),
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
                child: null, // No text on color buttons
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          if (!_isPlayingSequence && !_isPlayerTurn) // Show buttons only after sequence played or game over
             Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                     if (!_canRetryWithAd) // Show normal restart/next only if not in ad retry mode
                        ElevatedButton(onPressed: () => _restartGame(), child: Text('Restart Level')),
                     if (_message.startsWith("Correct!"))
                         ElevatedButton(onPressed: () => _restartGame(nextLevel: true), child: Text('Next Level')),
                 ],
             ),
            if (_canRetryWithAd)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: _attemptAdRetry,
                  child: Text('Watch Ad for Extra Try'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ),
        ],
      ),
    );
  }
}
