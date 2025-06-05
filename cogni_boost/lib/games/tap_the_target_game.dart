import 'package:flutter/material.dart';
import 'dart:math';

class TapTheTargetGame extends StatefulWidget {
  final Function(int score)? onGameCompleted;
  final Function()? onGameFlowFinished; // Ensure this is declared

  TapTheTargetGame({
    Key? key,
    this.onGameCompleted,
    this.onGameFlowFinished // Add to constructor parameters
  }) : super(key: key);

  @override
  _TapTheTargetGameState createState() => _TapTheTargetGameState();
}

class _TapTheTargetGameState extends State<TapTheTargetGame> {
  bool _targetVisible = false;
  Offset _targetPosition = Offset(50, 50);
  String _message = "Press 'Start Game' to begin";
  final Random _random = Random();
  final Stopwatch _stopwatch = Stopwatch();
  Size _screenSize = Size.zero; // To store screen size

  @override
  void didChangeDependencies() {
     super.didChangeDependencies();
     // Get screen size here as MediaQuery is available
     if (MediaQuery.of(context).size != Size.zero) {
        _screenSize = MediaQuery.of(context).size;
     } else {
        // Fallback if MediaQuery returns zero (less likely here but good for safety)
        _screenSize = Size(300,500); // Default if everything else fails
     }
  }

  void _startGame() {
    _stopwatch.reset();
    _stopwatch.start();
    setState(() {
      _message = "Get ready...";
      _targetVisible = false;
    });

    Future.delayed(Duration(milliseconds: _random.nextInt(2000) + 500), () { // Delay 0.5-2.5 seconds
      if (!mounted) return;

      // Ensure _screenSize is initialized (it should be by didChangeDependencies)
      if (_screenSize == Size.zero) {
         // This is an additional fallback, should ideally not be hit frequently.
         _screenSize = MediaQuery.of(context).size;
         if(_screenSize == Size.zero) _screenSize = Size(300,500); // Absolute fallback
      }

      // Keep target fully within screen bounds, considering target size (60x60)
      // And some padding from edges (e.g. 10px)
      double x = _random.nextDouble() * (_screenSize.width - 60 - 20) + 10;
      // Subtract more for appbar (~56) and potential bottom navigation/banner (~50-100)
      double y = _random.nextDouble() * (_screenSize.height - 60 - 56 - 100 - 20) + 10;

      _targetPosition = Offset(
          x.clamp(10.0, _screenSize.width - 70.0),
          y.clamp(10.0, _screenSize.height - 180.0) // Clamping to ensure visibility
      );

      setState(() {
        _targetVisible = true;
        _message = "Tap the target!";
      });
    });
  }

  void _onTargetTapped() {
    if (!_targetVisible) return;
    _stopwatch.stop();
    double reactionTimeMs = _stopwatch.elapsedMilliseconds.toDouble();
    // Score inversely proportional to time, higher score for faster reaction. Max 500.
    int score = ( (5000 - reactionTimeMs).clamp(0, 5000) / 10 ).toInt();

    widget.onGameCompleted?.call(score);

    setState(() {
      _targetVisible = false;
      _message = "Target Tapped! Score: $score";
    });

    // If part of a game flow (e.g. Daily Challenge), call the onGameFlowFinished callback.
    // Add a small delay for the user to see the score message.
    Future.delayed(Duration(milliseconds: 1500), () {
       if (!mounted) return;
       if (widget.onGameFlowFinished != null) {
         print("TapTheTargetGame: Triggering onGameFlowFinished.");
         widget.onGameFlowFinished?.call();
       } else {
         // If in practice mode, allow starting again
         setState(() {
           _message = "$_message. Play Again?";
         });
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tap the Target')),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_message, style: TextStyle(fontSize: 20.0), textAlign: TextAlign.center),
                SizedBox(height: 20),
                // Show "Start/Play Again" button only if not mid-game AND (in practice mode OR target not visible after game ended)
                if (!_stopwatch.isRunning && !_targetVisible && widget.onGameFlowFinished == null)
                  ElevatedButton(
                    onPressed: _startGame,
                    child: Text((_message.contains("Play Again?") || _message.contains("Target Tapped!")) && widget.onGameFlowFinished == null ?
                                'Play Again' :
                                'Start Game'),
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
