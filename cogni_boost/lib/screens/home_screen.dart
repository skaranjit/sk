// cogni_boost/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../games/sequence_recall_game.dart';
import '../games/tap_the_target_game.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'game_screen.dart';
import '../models/game_type.dart';
import '../services/ad_helper.dart'; // Import AdHelper
import '../games/pattern_recognition_game.dart'; // New import

class HomeScreen extends StatefulWidget { // Changed to StatefulWidget
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> { // New State class
  final List<GameType> _dailyGames = [
    GameType.sequenceRecall,
    GameType.tapTheTarget,
    GameType.patternRecognition, // Added new game
  ];
  late AdHelper _adHelper; // AdHelper instance
  int _currentStreak = 0;
  // String? _lastCompletionDateForDisplay; // Optional for more detailed messages

  final ScoreService _scoreService = ScoreService(); // Instance for streak data

  @override
  void initState() {
    super.initState();
    _adHelper = AdHelper();
    _adHelper.loadInterstitialAd();
    _loadStreakData(); // Load streak on init
  }

  Future<void> _loadStreakData() async {
    Map<String, dynamic> streakData = await _scoreService.getStreakData();
    if (mounted) {
      setState(() {
        _currentStreak = streakData['streakCount'];
        // _lastCompletionDateForDisplay = streakData['lastCompletionDate']; // If needed
      });
    }
  }

  @override
  void dispose() {
    _adHelper.dispose(); // Dispose AdHelper
    super.dispose();
  }

  void _navigateToStatsScreen() {
     _adHelper.showInterstitialAd(onAdDismissed: () {
         if(mounted) { // Check if widget is still in the tree
             Navigator.of(context).push(MaterialPageRoute(
                 builder: (context) => StatsScreen(),
             ));
         }
     });
  }

  void _navigateToProfileScreen() {
     _adHelper.showInterstitialAd(onAdDismissed: () {
         if(mounted) {
             Navigator.of(context).push(MaterialPageRoute(
                 builder: (context) => ProfileScreen(),
             ));
         }
     });
  }

  void _navigateToDailyChallenge() async { // Make it async to await result
     final result = await Navigator.of(context).push(MaterialPageRoute(
         builder: (context) => GameScreen(dailyChallengeGames: _dailyGames),
     ));

     if (result == true && mounted) { // If challenge was completed
         _loadStreakData(); // Refresh streak display
     }
  }

  void _navigateToPracticeSequence() {
     Navigator.of(context).push(MaterialPageRoute(
         builder: (context) => SequenceRecallGame(key: UniqueKey()),
     ));
  }

  void _navigateToPracticeTapTarget() {
     Navigator.of(context).push(MaterialPageRoute(
         builder: (context) => TapTheTargetGame(key: UniqueKey()),
     ));
  }

  void _navigateToPracticePatternRecognition() { // New method
     Navigator.of(context).push(MaterialPageRoute(
         builder: (context) => PatternRecognitionGame(key: UniqueKey()), // No callbacks for practice
     ));
  }

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
                 SizedBox(height: 10),
                 // Display Streak
                 if (_currentStreak > 0)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                            SizedBox(width: 8),
                            Text('Current Streak: $_currentStreak day(s)!', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orangeAccent)),
                        ],
                    ),
                 SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.play_circle_outline),
                label: Text('Play Daily Challenge'),
                   onPressed: _navigateToDailyChallenge,
              ),
              SizedBox(height: 30),
              Text('Practice Zone', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 10),
              OutlinedButton.icon(
                icon: Icon(Icons.memory),
                label: Text('Practice Sequence Recall'),
                onPressed: _navigateToPracticeSequence, // Updated
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary, side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                icon: Icon(Icons.ads_click),
                label: Text('Practice Tap the Target'),
                onPressed: _navigateToPracticeTapTarget, // Updated
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary, side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                icon: Icon(Icons.grid_view_rounded), // Example Icon
                label: Text('Practice Pattern Recognition'),
                onPressed: _navigateToPracticePatternRecognition,
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary, side: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              ),
              SizedBox(height: 30),
              Text('Your Progress', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.bar_chart),
                label: Text('View Stats'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white),
                onPressed: _navigateToStatsScreen, // Updated to use new method
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.settings),
                label: Text('Profile/Settings'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white),
                onPressed: _navigateToProfileScreen, // Updated to use new method
              ),
            ],
          ),
        ),
      ),
    );
  }
}
