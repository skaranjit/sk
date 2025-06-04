// cogni_boost/lib/services/ad_helper.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdHelper {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Use test ad unit IDs.
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('$ad loaded.');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _setFullScreenContentCallback(); // Set callbacks after ad is loaded
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _isRewardedAdReady = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void _setFullScreenContentCallback(){
     if (_rewardedAd == null) return;
     _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
         onAdShowedFullScreenContent: (RewardedAd ad) => print('$ad onAdShowedFullScreenContent.'),
         onAdDismissedFullScreenContent: (RewardedAd ad) {
             print('$ad onAdDismissedFullScreenContent.');
             ad.dispose();
             _rewardedAd = null; // Important to nullify
             _isRewardedAdReady = false;
             loadRewardedAd(); // Preload next ad
         },
         onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
             print('$ad onAdFailedToShowFullScreenContent: $error');
             ad.dispose();
             _rewardedAd = null;
             _isRewardedAdReady = false;
             loadRewardedAd();
         },
     );
  }

  void showRewardedAd(Function onUserEarnedRewardCallback) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('Reward earned: ${reward.amount} ${reward.type}');
        onUserEarnedRewardCallback();
      });
      // _rewardedAd = null; // Ad is single use, nullify it here or in onAdDismissedFullScreenContent
      // _isRewardedAdReady = false;
      // loadRewardedAd(); // Preload the next ad after showing
    } else {
      print('Rewarded ad is not ready yet.');
      // Optionally, load an ad if not ready, or inform the user.
      loadRewardedAd(); // Attempt to load if not ready
    }
  }

  void dispose() {
     _rewardedAd?.dispose();
  }
}
