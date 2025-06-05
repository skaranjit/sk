// cogni_boost/lib/services/ad_helper.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdHelper {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  InterstitialAd? _interstitialAd; // New
  bool _isInterstitialAdReady = false; // New
  static DateTime? _lastInterstitialShowTime; // Changed to static

  // Test Ad Unit IDs
  // No specific state needed in AdHelper for banner ads if each screen manages its own instance.

  static String get bannerAdUnitId { // New
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    throw UnsupportedError('Unsupported platform for banner ad');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    throw UnsupportedError('Unsupported platform for rewarded ad');
  }

  static String get interstitialAdUnitId { // New
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    throw UnsupportedError('Unsupported platform for interstitial ad');
  }

  void loadRewardedAd() {
    if (_rewardedAd != null) return; // Already loaded or loading
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('RewardedAd loaded.');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _setRewardedAdFullScreenContentCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  void _setRewardedAdFullScreenContentCallback() {
     if (_rewardedAd == null) return;
     _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
         onAdShowedFullScreenContent: (RewardedAd ad) => print('RewardedAd onAdShowedFullScreenContent.'),
         onAdDismissedFullScreenContent: (RewardedAd ad) {
             print('RewardedAd onAdDismissedFullScreenContent.');
             ad.dispose();
             _rewardedAd = null;
             _isRewardedAdReady = false;
             loadRewardedAd(); // Preload next ad
         },
         onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
             print('RewardedAd onAdFailedToShowFullScreenContent: $error');
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
      // Ad is disposed and reloaded in onAdDismissedFullScreenContent or onAdFailedToShowFullScreenContent
    } else {
      print('Rewarded ad is not ready yet.');
      loadRewardedAd(); // Attempt to load if not ready
    }
  }

  // --- Interstitial Ad Methods ---
  void loadInterstitialAd() { // New
    if (_interstitialAd != null) return; // Already loaded or loading
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('InterstitialAd loaded.');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setInterstitialAdFullScreenContentCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _setInterstitialAdFullScreenContentCallback() { // New
     if (_interstitialAd == null) return;
     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
         onAdShowedFullScreenContent: (InterstitialAd ad) => print('InterstitialAd onAdShowedFullScreenContent.'),
         onAdDismissedFullScreenContent: (InterstitialAd ad) {
             print('InterstitialAd onAdDismissedFullScreenContent.');
             ad.dispose();
             _interstitialAd = null;
             _isInterstitialAdReady = false;
             loadInterstitialAd(); // Preload next ad
         },
         onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
             print('InterstitialAd onAdFailedToShowFullScreenContent: $error');
             ad.dispose();
             _interstitialAd = null;
             _isInterstitialAdReady = false;
             loadInterstitialAd();
         },
     );
  }

  void showInterstitialAd({Function? onAdDismissed}) { // New, added optional callback
    // Simple frequency capping: only show if more than 2 minutes passed
    if (AdHelper._lastInterstitialShowTime != null &&
        DateTime.now().difference(AdHelper._lastInterstitialShowTime!).inMinutes < 2) { // Access via AdHelper.
         print("Interstitial ad skipped due to frequency capping.");
         onAdDismissed?.call(); // Call dismiss callback immediately if skipped
         return;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      // If we have a specific onAdDismissed for this call, chain it with the general one
      // This logic for chaining callbacks needs to be careful about how FullScreenContentCallback is structured.
      // The SDK might overwrite callbacks or not support chaining easily.
      // A simpler approach for this PoC is to rely on the one set during load,
      // and the calling site handles navigation after showInterstitialAd completes.
      // For this iteration, let's use the onAdDismissed provided to this specific call.

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) => print('InterstitialAd onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
            print('InterstitialAd onAdDismissedFullScreenContent (custom handler).');
            ad.dispose();
            _interstitialAd = null;
            _isInterstitialAdReady = false;
            onAdDismissed?.call(); // Call the specific dismiss callback
            loadInterstitialAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
            print('InterstitialAd onAdFailedToShowFullScreenContent: $error');
            ad.dispose();
            _interstitialAd = null;
            _isInterstitialAdReady = false;
            onAdDismissed?.call(); // Also call on dismiss if it failed to show
            loadInterstitialAd();
        },
      );


      _interstitialAd!.show();
      AdHelper._lastInterstitialShowTime = DateTime.now(); // Access via AdHelper.
      // Ad is disposed and reloaded in onAdDismissedFullScreenContent or onAdFailedToShowFullScreenContent
    } else {
      print('Interstitial ad is not ready yet.');
      onAdDismissed?.call(); // Call dismiss callback if not ready
      loadInterstitialAd(); // Attempt to load if not ready
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }

  BannerAd? createBannerAd({
     required AdSize adSize,
     required Function(Ad) onAdLoaded,
     required Function(LoadAdError) onAdFailedToLoad,
  }) { // New method
     final BannerAd bannerAd = BannerAd(
         adUnitId: bannerAdUnitId,
         size: adSize,
         request: AdRequest(),
         listener: BannerAdListener(
             onAdLoaded: (Ad ad) {
                 print('BannerAd loaded.');
                 onAdLoaded(ad);
             },
             onAdFailedToLoad: (Ad ad, LoadAdError error) {
                 print('BannerAd failed to load: $error');
                 ad.dispose();
                 onAdFailedToLoad(error);
             },
             onAdOpened: (Ad ad) => print('BannerAd onAdOpened.'),
             onAdClosed: (Ad ad) => print('BannerAd onAdClosed.'),
             onAdImpression: (Ad ad) => print('BannerAd onAdImpression.'),
         ),
     );
     bannerAd.load(); // Load the ad
     return bannerAd;
  }
}
