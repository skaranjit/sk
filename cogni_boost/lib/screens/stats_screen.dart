// cogni_boost/lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import AdWidget
import '../services/ad_helper.dart';
import '../services/score_service.dart';
import '../models/game_score.dart';
import '../models/game_type.dart';
import 'package:intl/intl.dart';
import '../utils/string_extensions.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<GameScore> _scores = [];
  bool _isLoading = true;
  final ScoreService _scoreService = ScoreService();

  AdHelper? _adHelper;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadScores();

    _adHelper = AdHelper();
    _bannerAd = _adHelper!.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (Ad ad) {
        if(mounted){
             setState(() {
                 _bannerAd = ad as BannerAd;
                 _isBannerAdLoaded = true;
             });
        }
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('Banner ad failed to load: $error');
        _bannerAd?.dispose();
        _bannerAd = null;
        // No need to setState for _isBannerAdLoaded as it's already false
      }
    );
  }

  Future<void> _loadScores() async {
    setState(() { _isLoading = true; });
    List<GameScore> scores = await _scoreService.getScores();
    scores.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if(mounted){
         setState(() {
             _scores = scores;
             _isLoading = false;
         });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    // _adHelper?.dispose(); // AdHelper's dispose is for its own interstitial/rewarded ads
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Statistics')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
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
                          IconData gameIcon = Icons.help_outline;
                          if (gameScore.gameType == GameType.sequenceRecall) gameIcon = Icons.memory;
                          if (gameScore.gameType == GameType.tapTheTarget) gameIcon = Icons.ads_click;

                          return Card(
                            elevation: 2.0,
                            margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                            child: ListTile(
                              leading: Icon(gameIcon, color: Theme.of(context).primaryColorLight),
                              title: Text('${gameScore.gameType.name.capitalizeWords()} - Score: ${gameScore.score}'),
                              subtitle: Text(DateFormat.yMMMd().add_jms().format(gameScore.timestamp)),
                              trailing: Icon(Icons.star, color: Colors.amber),
                            ),
                          );
                        },
                      ),
          ),
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadScores,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Scores',
      ),
    );
  }
}
