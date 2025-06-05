// cogni_boost/lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import AdWidget
import '../services/ad_helper.dart'; // Import AdHelper

class ProfileScreen extends StatefulWidget { // Changed to StatefulWidget
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> { // New State class
  AdHelper? _adHelper;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();

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
        print('ProfileScreen Banner ad failed to load: $error');
        _bannerAd?.dispose();
        _bannerAd = null;
      }
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Settings')),
      body: Column( // Wrap body in Column
        children: [
          Expanded( // Main content (ListView) takes available space
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: <Widget>[
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                SizedBox(height: 10),
                Center(child: Text("User Name", style: Theme.of(context).textTheme.headlineSmall)),
                SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary),
                        title: Text('Notification Settings'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () { /* Navigate to notification settings */ },
                      ),
                      ListTile(
                        leading: Icon(Icons.palette, color: Theme.of(context).colorScheme.secondary),
                        title: Text('Appearance'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () { /* Navigate to appearance settings */ },
                      ),
                      ListTile(
                        leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.secondary),
                        title: Text('Account & Security'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () { /* Navigate to account settings */ },
                      ),
                      ListTile(
                        leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.secondary),
                        title: Text('Help & Support'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () { /* Navigate to help page */ },
                      ),
                      ListTile(
                        leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                        title: Text('About CogniBoost'),
                        onTap: () { /* Show about dialog */ },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], foregroundColor: Colors.white),
                    onPressed: () { /* Handle Logout */ },
                    child: Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
          if (_isBannerAdLoaded && _bannerAd != null) // Banner Ad Container
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
