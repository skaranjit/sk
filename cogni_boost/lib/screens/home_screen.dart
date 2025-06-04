// cogni_boost/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../games/sequence_recall_game.dart';
import '../games/tap_the_target_game.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'game_screen.dart'; // Import GameScreen
import '../models/game_type.dart'; // Import GameType

class HomeScreen extends StatelessWidget {
  // Predefined daily challenge
  final List<GameType> _dailyGames = [
    GameType.sequenceRecall,
    GameType.tapTheTarget,
    GameType.sequenceRecall, // Example: play sequence recall again
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CogniBoost Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Welcome to CogniBoost!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColorDark)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.play_circle_outline),
                label: Text('Play Daily Challenge'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GameScreen(dailyChallengeGames: _dailyGames),
                  ));
                },
              ),
              SizedBox(height: 30),
              Text('Practice Zone', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 10),
              OutlinedButton.icon( // Using OutlinedButton for practice for differentiation
                icon: Icon(Icons.memory),
                label: Text('Practice Sequence Recall'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SequenceRecallGame(key: UniqueKey()),
                  ));
                },
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary, side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                icon: Icon(Icons.ads_click),
                label: Text('Practice Tap the Target'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TapTheTargetGame(key: UniqueKey()),
                  ));
                },
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary, side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              ),
              SizedBox(height: 30),
              Text('Your Progress', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.bar_chart),
                label: Text('View Stats'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StatsScreen(),
                  ));
                },
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.settings),
                label: Text('Profile/Settings'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
