// cogni_boost/lib/games/tap_the_target_game.dart
import 'package:flutter/material.dart';
import 'dart:math';

class TapTheTargetGame extends StatefulWidget {
  final Function(int score)? onGameCompleted; // Add this
  TapTheTargetGame({Key? key, this.onGameCompleted}) : super(key: key);
  @override
  _TapTheTargetGameState createState() => _TapTheTargetGameState();
}

class _TapTheTargetGameState extends State<TapTheTargetGame> {
  bool _targetVisible = false;
  Offset _targetPosition = Offset(50, 50); // Default position
  String _message = "Press 'Start Game' to begin";
  Random _random = Random();
  Stopwatch _stopwatch = Stopwatch();

  void _startGame() {
    _stopwatch.reset();
    setState(() {
      _message = "Get ready...";
      _targetVisible = false; // Hide target initially
    });

    // Short delay before showing the target
    Future.delayed(Duration(seconds: _random.nextInt(3) + 1), () { // Delay 1-3 seconds
      if (!mounted) return;
      setState(() {
        // Get screen dimensions via MediaQuery in build, but for PoC use fixed bounds
        // Assuming a screen area, for example, 300x500 for positioning
        double x = _random.nextDouble() * 250; // Keep within some bounds
        double y = _random.nextDouble() * 400;
        _targetPosition = Offset(x, y);
        _targetVisible = true;
        _message = "Tap the target!";
        _stopwatch.start();
      });
    });
  }

  void _onTargetTapped() {
    if (!_targetVisible) return;
    _stopwatch.stop();
    double reactionTimeMs = _stopwatch.elapsedMilliseconds.toDouble();
    int score = max(0, (5000 - reactionTimeMs.toInt()) ~/ 10); // Example: score inversely proportional to time
    setState(() {
      _targetVisible = false;
      _message = "Target Tapped! Score: $score. Play Again?";
    });
    widget.onGameCompleted?.call(score); // Report score
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tap the Target')),
      body: Stack( // Use Stack to position target absolutely
        children: <Widget>[
          Center( // Message and button centered
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_message, style: TextStyle(fontSize: 20.0), textAlign: TextAlign.center),
                SizedBox(height: 20),
                if (!_targetVisible && !_stopwatch.isRunning) // Show start button if game not active
                  ElevatedButton(
                    onPressed: _startGame,
                    child: Text(_message.contains("Play Again?") ? 'Play Again' : 'Start Game'),
                  ),
              ],
            ),
          ),
          if (_targetVisible)
            Positioned(
              left: _targetPosition.dx,
              top: _targetPosition.dy,
              child: GestureDetector(
                onTap: _onTargetTapped,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
