// cogni_boost/lib/games/pattern_recognition_game.dart
import 'package:flutter/material.dart';
import 'dart:math';

// For PoC, let's define simple item types. Could be expanded to shapes, numbers etc.
enum PatternItemType { color }

class PatternItem {
  final PatternItemType type;
  final Color? colorValue; // Used if type is color
  // final IconData? iconValue; // Example for future expansion
  // final String? textValue; // Example for future expansion

  PatternItem({required this.type, this.colorValue});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternItem &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          colorValue == other.colorValue;

  @override
  int get hashCode => type.hashCode ^ colorValue.hashCode;

  Widget displayWidget({double size = 40.0}) {
     if (type == PatternItemType.color && colorValue != null) {
         return Container(width: size, height: size, color: colorValue);
     }
     return Container(width: size, height: size, child: Icon(Icons.help_outline)); // Placeholder
  }
}

class PatternRecognitionGame extends StatefulWidget {
  final Function(int score)? onGameCompleted;
  final Function()? onGameFlowFinished;

  PatternRecognitionGame({Key? key, this.onGameCompleted, this.onGameFlowFinished}) : super(key: key);

  @override
  _PatternRecognitionGameState createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  List<PatternItem> _sequence = [];
  List<PatternItem> _options = [];
  PatternItem? _correctAnswer;
  String _message = "What comes next in the sequence?";
  bool _answered = false;
  int _score = 0; // Simple score for this game session

  final List<Color> _availableColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple, Colors.orange];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewPattern();
  }

  void _generateRepeatingColorPattern() {
    _sequence.clear();
    _options.clear();
    _answered = false;
    _message = "What comes next in the sequence?";

    int patternLength = _random.nextInt(2) + 2; // Repeating pattern of 2 or 3 colors
    List<PatternItem> basePattern = [];
    for (int i = 0; i < patternLength; i++) {
      basePattern.add(PatternItem(type: PatternItemType.color, colorValue: _availableColors[_random.nextInt(_availableColors.length)]));
    }

    // Display the pattern part, then ask for the next
    // e.g., A,B,A -> Correct: B
    // e.g., A,B,C,A,B -> Correct: C
    int sequenceDisplayLength = patternLength + _random.nextInt(patternLength); // Show 1 to almost 2 full repetitions
    if (sequenceDisplayLength < 3 && patternLength >1) sequenceDisplayLength = 3; // ensure at least 3 items if possible
    if (sequenceDisplayLength > 5) sequenceDisplayLength = 5; // Cap display length for PoC

    for(int i=0; i<sequenceDisplayLength; i++){
        _sequence.add(basePattern[i % patternLength]);
    }

    _correctAnswer = basePattern[sequenceDisplayLength % patternLength];

    // Generate options
    _options.add(_correctAnswer!);
    List<Color> tempAvailableColors = List.from(_availableColors); // Create a mutable copy
    tempAvailableColors.remove(_correctAnswer!.colorValue); // Remove correct answer to avoid duplicates in options (if possible)
    tempAvailableColors.shuffle(_random);

    for (int i = 0; i < 2; i++) { // Add 2 more wrong options
      if (tempAvailableColors.isNotEmpty) {
         _options.add(PatternItem(type: PatternItemType.color, colorValue: tempAvailableColors.removeAt(0)));
      } else {
        // Fallback if not enough unique colors (e.g. if _availableColors is small)
        _options.add(PatternItem(type: PatternItemType.color, colorValue: _availableColors[_random.nextInt(_availableColors.length)]));
      }
    }
    _options.shuffle(_random);
  }

  void _generateNewPattern(){
     // For now, only one pattern type. Could add more here.
     _generateRepeatingColorPattern();
  }

  void _onOptionTapped(PatternItem selectedOption) {
    if (_answered) return;

    setState(() {
      _answered = true;
      if (selectedOption == _correctAnswer) {
        _message = "Correct!";
        _score++;
      } else {
        _message = "Incorrect. The answer was:";
      }
    });

    widget.onGameCompleted?.call(_score);

    Future.delayed(Duration(seconds: 2), () {
      if (widget.onGameFlowFinished != null) {
        widget.onGameFlowFinished?.call();
      } else {
        if(mounted){
          setState(() {
            _generateNewPattern();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pattern Recognition')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_message, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text("SEQUENCE:", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _sequence.map((item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: item.displayWidget(size: 30),
              )).toList(),
            ),
            SizedBox(height: 30),
             Text("CHOOSE NEXT:", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            if (!_answered || (_answered && _message.startsWith("Incorrect")))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _options.map((option) {
                  return GestureDetector(
                    onTap: () => _onOptionTapped(option),
                    child: option.displayWidget(size: 50),
                  );
                }).toList(),
              ),
            if (_answered && _message.startsWith("Incorrect") && _correctAnswer != null)
             Padding(
                 padding: const EdgeInsets.only(top: 10.0),
                 child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Correct was: "), _correctAnswer!.displayWidget(size:50)])
             ),
            SizedBox(height: 30),
            if (widget.onGameFlowFinished == null && _answered)
              ElevatedButton(
                onPressed: () => setState(() { _generateNewPattern(); }),
                child: Text('Next Pattern'),
              ),
            if (widget.onGameFlowFinished == null)
               Padding(
                 padding: const EdgeInsets.only(top: 20.0),
                 child: Text("Score in this practice session: $_score", style: TextStyle(fontSize: 16)),
               )
          ],
        ),
      ),
    );
  }
}
