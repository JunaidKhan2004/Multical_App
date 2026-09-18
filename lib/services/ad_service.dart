import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Initializes the Mobile Ads SDK, hands out the banner ad unit ID, and
/// manages a preloaded interstitial shown every [_interstitialEvery]th call
/// to [maybeShowInterstitial].
///
/// Uses Google's public TEST ad unit IDs in debug builds so development
/// never serves (and never accidentally clicks) real ads — swap the
/// `_prodBanner*`/`_prodInterstitial*` constants for your own AdMob unit
/// IDs before a release build.
class AdService {
  AdService._();

  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const _prodBannerAndroid = 'ca-app-pub-5701334230119067/8857991153';
  // TODO: replace with your real iOS AdMob banner ad unit ID before release.
  static const _prodBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  static const _prodInterstitialAndroid =
      'ca-app-pub-5701334230119067/2292582809';
  // TODO: replace with your real iOS AdMob interstitial ad unit ID before release.
  static const _prodInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  /// Show an interstitial on every Nth call to [maybeShowInterstitial].
  static const _interstitialEvery = 3;

  // TEMPORARY: force real ad unit IDs in debug builds to test the new
  // AdMob ad units. Set back to false before normal development.
  static const _forceProdAdsInDebug = true;

  static const _maxLoadRetries = 3;
  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];

  static int _navCount = 0;
  static InterstitialAd? _interstitial;
  static bool _loadingInterstitial = false;
  static int _loadAttempt = 0;

  // Real device IDs seen in "Use RequestConfiguration.Builder()..." log
  // lines. Registering them as test devices makes AdMob serve real test
  // ads to them even while this AdMob account/app is otherwise restricted
  // (e.g. pending app-store listing verification).
  static const _testDeviceIds = ['1C9A421D63A6A9C24BB216AC77FEEF5C'];

  static Future<void> init() async {
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: _testDeviceIds),
      );
    }
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  static String get bannerAdUnitId {
    final useTest = kDebugMode && !_forceProdAdsInDebug;
    if (Platform.isAndroid) {
      return useTest ? _testBannerAndroid : _prodBannerAndroid;
    }
    if (Platform.isIOS) {
      return useTest ? _testBannerIOS : _prodBannerIOS;
    }
    throw UnsupportedError('Ads are only supported on Android and iOS');
  }

  static String get _interstitialAdUnitId {
    final useTest = kDebugMode && !_forceProdAdsInDebug;
    if (Platform.isAndroid) {
      return useTest ? _testInterstitialAndroid : _prodInterstitialAndroid;
    }
    if (Platform.isIOS) {
      return useTest ? _testInterstitialIOS : _prodInterstitialIOS;
    }
    throw UnsupportedError('Ads are only supported on Android and iOS');
  }

  static void _loadInterstitial() {
    if (_loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _loadAttempt = 0;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
          );
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint(
            'InterstitialAd failed: code=${error.code} domain=${error.domain} '
            'message=${error.message}',
          );
          // NO_FILL and transient network errors are common and usually
          // resolve on their own — retry a few times with backoff before
          // giving up until the next natural reload trigger.
          if (_loadAttempt < _maxLoadRetries) {
            final delay = _retryDelays[_loadAttempt];
            _loadAttempt++;
            Future.delayed(delay, _loadInterstitial);
          } else {
            _loadAttempt = 0;
          }
        },
      ),
    );
  }

  /// Call at a natural navigation break (e.g. opening a calculator from the
  /// home grid). Shows the preloaded interstitial every [_interstitialEvery]
  /// calls; a no-op (and doesn't consume the count) if none is loaded yet.
  static void maybeShowInterstitial() {
    _navCount++;
    if (_navCount % _interstitialEvery != 0) return;
    final ad = _interstitial;
    if (ad == null) return;
    _interstitial = null;
    ad.show();
  }
}
