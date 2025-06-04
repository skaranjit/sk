// cogni_boost/lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import '../services/score_service.dart';
import '../models/game_score.dart';
import '../models/game_type.dart'; // Ensure GameType is imported
import 'package:intl/intl.dart'; // For date formatting
import '../utils/string_extensions.dart'; // Import the string extension

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<GameScore> _scores = [];
  bool _isLoading = true;
  final ScoreService _scoreService = ScoreService();

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() { _isLoading = true; });
    List<GameScore> scores = await _scoreService.getScores();
    // Sort scores by timestamp, newest first
    scores.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if(mounted){
         setState(() {
             _scores = scores;
             _isLoading = false;
         });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Statistics')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _scores.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey),
                      SizedBox(height:10),
                      Text('No scores yet. Play some games!', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ))
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: _scores.length,
                  itemBuilder: (context, index) {
                    final gameScore = _scores[index];
                    IconData gameIcon = Icons.help_outline; // Default icon
                    if (gameScore.gameType == GameType.sequenceRecall) gameIcon = Icons.memory;
                    if (gameScore.gameType == GameType.tapTheTarget) gameIcon = Icons.ads_click;

                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      child: ListTile(
                        leading: Icon(gameIcon, color: Theme.of(context).primaryColorLight),
                        title: Text('${gameScore.gameType.name.capitalizeWords()} - Score: ${gameScore.score}'),
                        subtitle: Text(DateFormat.yMMMd().add_jms().format(gameScore.timestamp)),
                        trailing: Icon(Icons.star, color: Colors.amber), // Example trailing icon
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadScores,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Scores',
      ),
    );
  }
}
